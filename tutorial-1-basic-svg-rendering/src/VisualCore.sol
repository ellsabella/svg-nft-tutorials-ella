// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {FontStore} from "./FontStore.sol";

interface IVisualCore {
    function createAllFilters(
        uint256 seed
    ) external pure returns (string memory);

    function generateBackground(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function createFrames(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function generateRandomText(
        uint256 seed,
        uint8 length
    ) external pure returns (string memory);
}

contract VisualCore is IVisualCore {
    bytes constant CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789";

    function createAllFilters(
        uint256 seed
    ) external pure override returns (string memory) {
        return
            string.concat(
                "<defs>",
                _createOriginalBlurFilter(),
                _createNeonPortalGradients(),
                // _createDynamicGlitchFilters(seed),
                _createFrameGradients(), // MOVE frame gradients here
                "</defs>"
            );
    }

    function generateRandomText(
        uint256 seed,
        uint8 length
    ) external pure override returns (string memory) {
        bytes memory chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory text = new bytes(length);

        uint256 s = seed;
        for (uint8 i = 0; i < length; i++) {
            text[i] = chars[s % 36];
            s = s >> 4;
        }

        return string(text);
    }

    function _createDynamicGlitchFilters(
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                // Glitch shift filter with dynamic seed
                '<filter id="glitchShift" x="-25%" y="-25%" width="150%" height="150%">',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + (seed % 21)), // 12-32 range
                'e-2" numOctaves="1" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                '<feDisplacementMap in="SourceGraphic" in2="bands" scale="28" ',
                'xChannelSelector="R" yChannelSelector="R" result="distorted"/>',
                '<feOffset in="distorted" dx="2" dy="0" result="red"/>',
                '<feOffset in="distorted" dx="-2" dy="0" result="cyan"/>',
                '<feComposite in="red" in2="cyan" operator="lighter" result="merged"/>',
                '<feMerge><feMergeNode in="merged"/></feMerge>',
                "</filter>",
                // Glitch blur filter with dynamic seed
                '<filter id="glitchBlur" x="-25%" y="-25%" width="150%" height="150%">',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blurred"/>',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + ((seed * 7919) % 21)), // Different seed calculation
                'e-2" numOctaves="1" seed="',
                Strings.toString((seed * 2654435761) % 10000), // Large prime for variation
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                '<feDisplacementMap in="blurred" in2="bands" scale="28" ',
                'xChannelSelector="R" yChannelSelector="R" result="distBlur"/>',
                '<feOffset in="distBlur" dx="2" dy="0" result="r"/>',
                '<feOffset in="distBlur" dx="-2" dy="0" result="c"/>',
                '<feComposite in="r" in2="c" operator="lighter" result="out"/>',
                '<feMerge><feMergeNode in="out"/></feMerge>',
                "</filter>"
            );
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

    function _createNeonPortalGradients()
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                '<linearGradient id="ring"><stop offset="0" stop-color="#00FFFF"/><stop offset="1" stop-color="#FF00FF"/></linearGradient>',
                '<radialGradient id="b1"><stop offset="0" stop-color="#004080" stop-opacity="0.3"/><stop offset="0.6" stop-color="#002040" stop-opacity="0.15"/><stop offset="1" stop-color="#000000" stop-opacity="0.02"/></radialGradient>',
                '<radialGradient id="b2"><stop offset="0" stop-color="#800040" stop-opacity="0.25"/><stop offset="0.7" stop-color="#400020" stop-opacity="0.1"/><stop offset="1" stop-color="#000000" stop-opacity="0.01"/></radialGradient>',
                '<radialGradient id="b3"><stop offset="0" stop-color="#408080" stop-opacity="0.2"/><stop offset="0.8" stop-color="#204040" stop-opacity="0.08"/><stop offset="1" stop-color="#000000" stop-opacity="0.005"/></radialGradient>'
            );
    }

    function generateBackground(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) external pure override returns (string memory) {
        return _createMirroredBackground(colorA, colorB);
    }

    function _createMirroredBackground(
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<rect width="1440" height="1440" fill="black"/>',
                _createGrid(colorA),
                _createTestText(colorB), // Pass colorB to text function
                '<rect width="1440" height="1440" fill="none" stroke="#333" stroke-width="1" opacity="0.2"/>'
            );
    }

    function _createTestText(
        string memory colorB
    ) internal pure returns (string memory) {
        string memory textCluster = _createTextCluster(colorB);

        return
            string.concat(
                "<g>",
                textCluster,
                "</g>",
                '<g transform="translate(200,150)">',
                textCluster,
                "</g>",
                '<g transform="translate(-180,-200)">',
                textCluster,
                "</g>",
                '<g transform="scale(-1,1) translate(-1440,0)">',
                textCluster,
                "</g>",
                '<g transform="scale(1,-1) translate(0,-1440)">',
                textCluster,
                "</g>",
                '<g transform="rotate(90 720 720)">',
                textCluster,
                "</g>"
            );
    }

    function _createGrid(
        string memory colorA
    ) internal pure returns (string memory) {
        // Create only top-left quadrant (720x720), then mirror
        string memory quadrantGrid = "";

        // Generate lines for top-left quadrant only
        for (uint16 i = 30; i <= 720; i += 30) {
            // Vertical line
            quadrantGrid = string.concat(
                quadrantGrid,
                '<line x1="',
                Strings.toString(i),
                '" y1="0" x2="',
                Strings.toString(i),
                '" y2="720" stroke="',
                colorA,
                '" stroke-width="1" opacity="0.7" filter="url(#blur)"/>'
            );
            // Horizontal line
            quadrantGrid = string.concat(
                quadrantGrid,
                '<line x1="0" y1="',
                Strings.toString(i),
                '" x2="720" y2="',
                Strings.toString(i),
                '" stroke="',
                colorA,
                '" stroke-width="1" opacity="0.7" filter="url(#blur)"/>'
            );
        }

        return
            string.concat(
                "<g>",
                quadrantGrid,
                "</g>",
                '<g transform="scale(-1,1) translate(-1440,0)">',
                quadrantGrid,
                "</g>",
                '<g transform="scale(1,-1) translate(0,-1440)">',
                quadrantGrid,
                "</g>",
                '<g transform="scale(-1,-1) translate(-1440,-1440)">',
                quadrantGrid,
                "</g>"
            );
    }

    function _createTextCluster(
        string memory colorB
    ) internal pure returns (string memory) {
        string memory baseText = string.concat(
            '<text x="600" y="650" class="f" font-size="80" fill="',
            colorB,
            '" opacity="0.1" filter="url(#blur)">ZRBBZR</text>'
        );

        return
            string.concat(
                baseText,
                '<g transform="translate(240,140)">',
                baseText,
                "</g>",
                '<g transform="translate(-120,280)">',
                baseText,
                "</g>",
                '<g transform="rotate(90 720 720)">',
                baseText,
                "</g>",
                '<g transform="rotate(180 720 720)">',
                baseText,
                "</g>"
            );
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

    function _createFrameGradientDefs(
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Outer frame gradient (B→A→B)
                '<linearGradient id="outerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0"   stop-color="',
                colorB,
                '"/>',
                '<stop offset="0.5" stop-color="',
                colorA,
                '"/>',
                '<stop offset="1"   stop-color="',
                colorB,
                '"/>',
                '<animateTransform attributeName="gradientTransform" '
                'type="rotate" values="0 0.5 0.5;360 0.5 0.5" dur="8s" '
                'repeatCount="indefinite"/>',
                "</linearGradient>",
                // Inner frame gradient (A→B→A)
                '<linearGradient id="innerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0"   stop-color="',
                colorA,
                '"/>',
                '<stop offset="0.5" stop-color="',
                colorB,
                '"/>',
                '<stop offset="1"   stop-color="',
                colorA,
                '"/>',
                '<animateTransform attributeName="gradientTransform" '
                'type="rotate" values="360 0.5 0.5;0 0.5 0.5" dur="10s" '
                'repeatCount="indefinite"/>',
                "</linearGradient>",
                "</defs>"
            );
    }

    function _createFrameGradients() internal pure returns (string memory) {
        return
            string.concat(
                // Outer frame gradient
                '<linearGradient id="outerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="var(--colorB)"/>',
                '<stop offset="0.5" stop-color="var(--colorA)"/>',
                '<stop offset="1" stop-color="var(--colorB)"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="0 0.5 0.5;360 0.5 0.5" dur="8s" repeatCount="indefinite"/>',
                "</linearGradient>",
                // Inner frame gradient
                '<linearGradient id="innerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="var(--colorA)"/>',
                '<stop offset="0.5" stop-color="var(--colorB)"/>',
                '<stop offset="1" stop-color="var(--colorA)"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="360 0.5 0.5;0 0.5 0.5" dur="10s" repeatCount="indefinite"/>',
                "</linearGradient>"
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

    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory) {
        return
            string.concat(
                "<defs><style>",
                ":root{--colorA:",
                colorA,
                ";--colorB:",
                colorB,
                ";}",
                "@font-face{font-family:'f';src:url(data:font/woff2;base64,",
                FontStore.fontBase64(),
                ") format('woff2');}",
                ".f{font-family:'f',monospace}",
                "</style></defs>"
            );
    }
}
