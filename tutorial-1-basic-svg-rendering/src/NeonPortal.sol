// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IVisualCore} from "./VisualCore.sol";
import {FontStore} from "./FontStore.sol";

interface INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse
    ) external view returns (string memory);

    // Add new function for animated portals
    function createAnimatedNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) external view returns (string memory);
}

contract NeonPortal is INeonPortal {
    IVisualCore public immutable visualCore;

    constructor(address core) {
        visualCore = IVisualCore(core);
    }

    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse
    ) external view override returns (string memory) {
        // Call the internal implementation directly
        return
            _createPortalInternal(x, y, size, seed, enablePulse, false, x, y);
    }

    function createAnimatedNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) external view override returns (string memory) {
        // Call the internal implementation directly
        return
            _createPortalInternal(
                x,
                y,
                size,
                seed,
                enablePulse,
                enableMovement,
                centerX,
                centerY
            );
    }

    function _createPortalInternal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) internal view returns (string memory) {
        if (size < 20) size = 20;
        bool enableGlitch = (seed % 2) == 0;

        string memory filterId = string.concat(
            "glitch",
            Strings.toString(seed % 10000)
        );

        string memory content = string.concat(
            enableGlitch
                ? string.concat(
                    "<defs>",
                    _createGlitchFilter(seed, filterId),
                    _createGlitchBlurFilter(seed, filterId),
                    "</defs>"
                )
                : "",
            _createBokeh(x, y, size, seed),
            _createTextLayer(x, y, size, seed),
            _createRings(x, y, size, enablePulse, enableGlitch, filterId)
        );

        // Wrap in movement animation if enabled
        if (enableMovement) {
            if (centerX == x && centerY == y) {
                // Single portal: grow/shrink animation
                return _wrapWithGrowShrinkAnimation(content, size);
            } else {
                // Multiple portals: orbital rotation around centerX, centerY
                return
                    _wrapWithOrbitalAnimation(content, x, y, centerX, centerY);
            }
        }

        return string.concat("<g>", content, "</g>");
    }

    function _wrapWithGrowShrinkAnimation(
        string memory content,
        uint16 size
    ) internal pure returns (string memory) {
        // Similar to red circles grow/shrink
        uint16 maxSize = size + 200; // Grow by 200px

        return
            string.concat(
                "<g>",
                '<animateTransform attributeName="transform" type="scale" ',
                'values="1;',
                _scaleValue(size, maxSize),
                ';1" ',
                'dur="5s" repeatCount="indefinite"/>',
                content,
                "</g>"
            );
    }

    function _wrapWithOrbitalAnimation(
        string memory content,
        uint16 x,
        uint16 y,
        uint16 centerX,
        uint16 centerY
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ')">',
                '<animateTransform attributeName="transform" type="rotate" ',
                'values="0 ',
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                ";360 ",
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                '" dur="8s" repeatCount="indefinite"/>',
                content,
                "</g>"
            );
    }

    function _scaleValue(
        uint16 baseSize,
        uint16 maxSize
    ) internal pure returns (string memory) {
        // Calculate scale factor: maxSize / baseSize
        uint256 scaleFactor = (uint256(maxSize) * 100) / uint256(baseSize);
        return
            string.concat(
                Strings.toString(scaleFactor / 100),
                ".",
                Strings.toString(scaleFactor % 100)
            );
    }

    function _createTextLayer(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed
    ) internal view returns (string memory) {
        string memory randomText = visualCore.generateRandomText(seed, 8);

        uint16 textX = x > 50 ? x - 30 : x + 30;
        uint16 textY = y + 10;

        return
            string.concat(
                '<text x="',
                Strings.toString(textX),
                '" y="',
                Strings.toString(textY),
                '" style="font-family:f,monospace;font-size:12px;fill:black;opacity:0.6">',
                randomText,
                "</text>"
            );
    }

    function _animDur(uint256 seed) internal pure returns (string memory) {
        uint256 d = 3 + (seed % 4); // 3-6 s
        return string.concat(Strings.toString(d), "s");
    }

    function _createGlitchBlurFilter(
        uint256 seed,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="',
                filterId,
                'Blur" x="-25%" y="-25%" width="150%" height="150%">',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blurred"/>',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + (seed % 21)),
                'e-2" numOctaves="1" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                '<feDisplacementMap in="blurred" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distBlur">',
                '<animate attributeName="scale" values="0;28;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                '<feOffset in="distBlur" dx="2"  dy="0" result="r"/>',
                '<feOffset in="distBlur" dx="-2" dy="0" result="c"/>',
                '<feComposite in="r" in2="c" operator="lighter" result="out"/>',
                '<feMerge><feMergeNode in="out"/></feMerge>',
                "</filter>"
            );
    }

    function _createGlitchFilter(
        uint256 seed,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="',
                filterId,
                'Shift" x="-25%" y="-25%" width="150%" height="150%">',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + (seed % 21)),
                'e-2" numOctaves="1" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                '<feDisplacementMap in="SourceGraphic" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distorted">',
                '<animate attributeName="scale" values="0;28;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                '<feOffset in="distorted" dx="2"  dy="0" result="red"/>',
                '<feOffset in="distorted" dx="-2" dy="0" result="cyan"/>',
                '<feComposite in="red" in2="cyan" operator="lighter" result="merged"/>',
                '<feMerge><feMergeNode in="merged"/></feMerge>',
                "</filter>"
            );
    }

    function _createBokeh(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                _bokehLayer(x, y, size, seed * 2654435761, 4, 7, 20, 40, "b1"),
                _bokehLayer(x, y, size, seed * 1073741827, 3, 9, 12, 25, "b2"),
                _bokehLayer(x, y, size, seed * 2147483647, 2, 11, 6, 15, "b3")
            );
    }

    function _bokehLayer(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        uint8 spread,
        uint8 count,
        uint8 minSize,
        uint8 sizeRange,
        string memory grad
    ) internal pure returns (string memory) {
        string memory result = "";

        for (uint8 i = 0; i < count; i++) {
            result = string.concat(
                result,
                _bokehCircle(
                    x,
                    y,
                    size,
                    seed + uint256(i) * 3571,
                    spread,
                    minSize,
                    sizeRange,
                    grad
                )
            );
        }
        return result;
    }

    function _bokehCircle(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 s,
        uint8 spread,
        uint8 minSize,
        uint8 sizeRange,
        string memory grad
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(_calcPosX(x, s, size, spread)),
                '" cy="',
                Strings.toString(_calcPosY(y, s * 7919, size, spread)),
                '" r="',
                Strings.toString(minSize + uint8((s >> 16) % sizeRange)),
                '" fill="url(#',
                grad,
                ')" filter="url(#blur)"/>'
            );
    }

    function _calcPosX(
        uint16 center,
        uint256 seed,
        uint16 size,
        uint8 spread
    ) internal pure returns (uint16) {
        uint256 halfBox = (uint256(size) * uint256(spread)) / 3;
        uint256 randomOffset = seed % (halfBox * 2);

        if (center > halfBox) {
            return center - uint16(halfBox) + uint16(randomOffset);
        } else {
            return uint16(randomOffset);
        }
    }

    function _calcPosY(
        uint16 center,
        uint256 seed,
        uint16 size,
        uint8 spread
    ) internal pure returns (uint16) {
        uint256 halfBox = (uint256(size) * uint256(spread)) / 3;
        uint256 randomOffset = (seed ^ 0xAAAAAAAA) % (halfBox * 2);

        if (center > halfBox) {
            return center - uint16(halfBox) + uint16(randomOffset);
        } else {
            return uint16(randomOffset);
        }
    }

    function _createRings(
        uint16 x,
        uint16 y,
        uint16 size,
        bool pulse,
        bool glitch,
        string memory filterId
    ) internal pure returns (string memory) {
        uint8 sw = _strokeWidth(size);

        string memory glowFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Blur)"')
            : ' filter="url(#blur)"';
        string memory crispFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Shift)"')
            : "";

        return
            string.concat(
                _ring(x, y, size, sw <= 5 ? sw * 3 : 15, "0.5", glowFilter),
                _ring(x, y, size, sw <= 5 ? sw * 2 : 10, "0.7", glowFilter),
                _ring(x, y, size, sw, "1", crispFilter),
                _highlight(x, y, size, pulse, glitch, filterId)
            );
    }

    function _ring(
        uint16 x,
        uint16 y,
        uint16 size,
        uint8 sw,
        string memory opacity,
        string memory filter
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#ring)" stroke-width="',
                Strings.toString(sw),
                '" opacity="',
                opacity,
                '"',
                filter,
                "/>"
            );
    }

    function _highlight(
        uint16 x,
        uint16 y,
        uint16 size,
        bool pulse,
        bool glitch,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory base = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
            glitch ? string.concat(' filter="url(#', filterId, 'Shift)"') : ""
        );

        return
            pulse
                ? string.concat(
                    base,
                    '><animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/><animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/></circle>'
                )
                : string.concat(base, "/>");
    }

    function _strokeWidth(uint16 size) internal pure returns (uint8) {
        if (size < 15) return 2;
        uint256 calc = (uint256(size) * 4) / 60;
        return uint8(calc < 2 ? 2 : calc > 15 ? 15 : calc);
    }
}
