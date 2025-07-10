// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IVisualCore {
    function createAllFilters() external pure returns (string memory);

    function generateBackground(
        uint256 tokenId,
        string memory colorA
    ) external pure returns (string memory);

    function createFrames(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);
}

contract VisualCore is IVisualCore {
    bytes constant CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";
    string constant LOCAL_FONT_FAMILY =
        "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";

    // === FILTERS ===
    function createAllFilters() external pure override returns (string memory) {
        return string.concat("<defs>", _createOriginalBlurFilter(), "</defs>");
    }

    function _createOriginalBlurFilter() internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="blur" filterUnits="userSpaceOnUse" ',
                'x="-720" y="-720" width="2160" height="2160">',
                // Multi-layer base glow
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="tight"/>',
                '<feColorMatrix in="tight" type="matrix" values="',
                '6 0 0 0 0 0 6 0 0 0 0 0 6 0 0 0 0 0 1.0 0" result="tightColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="15" result="medium"/>',
                '<feColorMatrix in="medium" type="matrix" values="',
                '4 0 0 0 0 0 4 0 0 0 0 0 4 0 0 0 0 0 0.8 0" result="mediumColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="35" result="wide"/>',
                '<feColorMatrix in="wide" type="matrix" values="',
                '2 0 0 0 0 0 2 0 0 0 0 0 2 0 0 0 0 0 0.6 0" result="wideColored"/>',
                "<feMerge>",
                '<feMergeNode in="wideColored"/>',
                '<feMergeNode in="mediumColored"/>',
                '<feMergeNode in="tightColored"/>',
                '<feMergeNode in="SourceGraphic"/>',
                "</feMerge>",
                "</filter>"
            );
    }

    // === BACKGROUND ===
    function generateBackground(
        uint256 tokenId,
        string memory colorA
    ) external pure override returns (string memory) {
        return
            string.concat(
                _createMirroredBackground(),
                _createOptimizedTextBackground(tokenId, colorA)
            );
    }

    function _createMirroredBackground() internal pure returns (string memory) {
        return
            string.concat(
                '<rect width="1440" height="1440" fill="black"/>',
                '<rect width="1440" height="1440" fill="none" stroke="#333" stroke-width="1" opacity="0.2"/>'
            );
    }

    function _createOptimizedTextBackground(
        uint256 tokenId,
        string memory colorA
    ) internal pure returns (string memory) {
        string memory baseUnit = _generateOptimizedTextUnit(tokenId);
        string memory dualLayer = _createOptimizedDualLayer(baseUnit, colorA);
        return _createOptimizedSuperGrid(dualLayer);
    }

    function _generateOptimizedTextUnit(
        uint256 tokenId
    ) internal pure returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId);

        // Pre-calculate full size: 8 tspans × ~55 chars each = ~440 bytes + markup
        bytes memory result = new bytes(600);
        uint256 pos;

        // Generate all 8 rows in single pass
        for (uint256 row; row < 8; ++row) {
            // Inline tspan creation - no intermediate strings
            bytes memory tspanStart = abi.encodePacked(
                '<tspan x="0" y="',
                Strings.toString(45 + row * 45),
                '">'
            );

            // Copy tspan opening
            for (uint256 i; i < tspanStart.length; ++i) {
                result[pos++] = tspanStart[i];
            }

            // Generate 8 characters directly into result
            for (uint256 col; col < 8; ++col) {
                result[pos++] = CHARS[Random.randInt(ctx) % 35];
            }

            // Close tspan
            result[pos++] = "<";
            result[pos++] = "/";
            result[pos++] = "t";
            result[pos++] = "s";
            result[pos++] = "p";
            result[pos++] = "a";
            result[pos++] = "n";
            result[pos++] = ">";
        }

        // Return exact-sized result
        bytes memory final2 = new bytes(pos);
        for (uint256 i; i < pos; ++i) {
            final2[i] = result[i];
        }

        return string(final2);
    }

    function _createOptimizedDualLayer(
        string memory baseUnit,
        string memory colorA
    ) internal pure returns (string memory) {
        return
            string.concat(
                // Layer 1: Base text
                '<text class="g f" font-size="42" fill="',
                colorA,
                '" opacity="0.05">',
                baseUnit,
                "</text>",
                // Layer 2: Horizontally mirrored for texture
                '<text class="g f" font-size="42" fill="',
                colorA,
                '" opacity="0.07" transform="scale(-1,1) translate(-360,0)">',
                baseUnit,
                "</text>"
            );
    }

    function _createOptimizedSuperGrid(
        string memory dualLayer
    ) internal pure returns (string memory) {
        string memory grid = "";

        // 4x4 grid of 360x360px super cells = 1440x1440 total
        for (uint256 i; i < 16; ++i) {
            uint256 col = i & 3; // i % 4
            uint256 row = i >> 2; // i / 4
            uint256 x = col * 360;
            uint256 y = row * 360;

            grid = string.concat(
                grid,
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ')">',
                dualLayer,
                "</g>"
            );
        }

        return grid;
    }

    // === FRAMES ===
    function createFrames(
        string memory colorA,
        string memory colorB
    ) external pure override returns (string memory) {
        return
            string.concat(
                _createFrameGradientDefs(colorA, colorB),
                _createOuterFrame(),
                _createInnerFrame()
            );
    }

    // === FRAME GRADIENT DEFINITIONS ===
    function _createFrameGradientDefs(
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Outer frame gradient: B to A (reverse) - rotating gradient
                '<linearGradient id="outerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="',
                colorB,
                '"/>',
                '<stop offset="0.5" stop-color="',
                colorA,
                '"/>',
                '<stop offset="1" stop-color="',
                colorB,
                '"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="0 0.5 0.5;360 0.5 0.5" dur="8s" repeatCount="indefinite"/>',
                "</linearGradient>",
                // Inner frame gradient: A to B (normal) - rotating gradient
                '<linearGradient id="innerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="',
                colorA,
                '"/>',
                '<stop offset="0.5" stop-color="',
                colorB,
                '"/>',
                '<stop offset="1" stop-color="',
                colorA,
                '"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="360 0.5 0.5;0 0.5 0.5" dur="10s" repeatCount="indefinite"/>',
                "</linearGradient>",
                "</defs>"
            );
    }

    // === OUTER FRAME (4 layers) ===
    function _createOuterFrame() internal pure returns (string memory) {
        return
            string.concat(
                // Wide glow layer
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="url(#outerFrameGrad)" stroke-width="30" filter="url(#blur)" opacity="0.5"/>',
                // Medium glow layer
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="url(#outerFrameGrad)" stroke-width="20" filter="url(#blur)" opacity="0.7"/>',
                // Crisp layer
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="url(#outerFrameGrad)" stroke-width="10"/>',
                // White hot layer (always pulsing)
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9">',
                '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="3s" repeatCount="indefinite"/>',
                '<animate attributeName="stroke-width" values="0.5;3;0.5" dur="3s" repeatCount="indefinite"/>',
                "</rect>"
            );
    }

    // === INNER FRAME (4 layers) ===
    function _createInnerFrame() internal pure returns (string memory) {
        return
            string.concat(
                // Wide glow layer
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="url(#innerFrameGrad)" stroke-width="30" filter="url(#blur)" opacity="0.5"/>',
                // Medium glow layer
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="url(#innerFrameGrad)" stroke-width="20" filter="url(#blur)" opacity="0.7"/>',
                // Crisp layer
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="url(#innerFrameGrad)" stroke-width="10"/>',
                // White hot layer (always pulsing)
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9">',
                '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="3s" repeatCount="indefinite"/>',
                '<animate attributeName="stroke-width" values="0.5;3;0.5" dur="3s" repeatCount="indefinite"/>',
                "</rect>"
            );
    }

    // === FRAMES ===
    // function createFrames(
    //     string memory colorA,
    //     string memory colorB
    // ) external pure override returns (string memory) {
    //     return
    //         string.concat(
    //             '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
    //             colorA,
    //             '" stroke-width="10" filter="url(#blur)"/>',
    //             '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
    //             colorA,
    //             '" stroke-width="10"/>',
    //             '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="',
    //             colorB,
    //             '" stroke-width="10" filter="url(#blur)"/>',
    //             '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="',
    //             colorB,
    //             '" stroke-width="10"/>'
    //         );
    // }

    // === TEXT STYLE ===
    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure override returns (string memory) {
        return
            string.concat(
                "<style>",
                "@font-face{font-family:'f';src:url(data:font/woff2;base64,",
                LOCAL_FONT_FAMILY,
                ')}.g{letter-spacing:0px}.f{font-family:"f",monospace}.a{fill:',
                colorA,
                "}.b{fill:",
                colorB,
                "}</style>"
            );
    }
}
