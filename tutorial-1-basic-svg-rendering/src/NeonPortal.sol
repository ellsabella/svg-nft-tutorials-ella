// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IVisualCore} from "./VisualCore.sol";
import {FontStore} from "./FontStore.sol";

interface INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse // Add parameter
    ) external view returns (string memory); // Change to view
}

contract NeonPortal is INeonPortal {
    IVisualCore public immutable visualCore; // ➊  stored reference

    constructor(address core) {
        visualCore = IVisualCore(core);
    }

    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external view override returns (string memory) {
        if (size < 20) size = 20;
        bool enableGlitch = (seed % 2) == 0;

        string memory filterId = string.concat(
            "glitch",
            Strings.toString(seed % 10000)
        );

        return
            string.concat(
                "<g>",
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
                _createRings(x, y, size, enablePulse, enableGlitch, filterId),
                "</g>"
            );
    }

    function _createTextLayer(
        uint16 x,
        uint16 y,
        uint8 size,
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
                '" style="font-family:f,monospace;font-size:12px;fill:black;opacity:0.6">', // Try inline style instead of class
                randomText,
                "</text>"
            );
    }

    /// @dev Pick a 3 – 6 s duration string from the seed
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
                /* —— glow first —— */
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="blurred"/>',
                /* —— static bar mask —— */
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + (seed % 21)),
                'e-2" numOctaves="1" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                /* —— displacement that breathes in/out —— */
                '<feDisplacementMap in="blurred" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distBlur">',
                '<animate attributeName="scale" values="0;28;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                /* —— optional magenta / cyan glow split —— */
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
                /* —— static bar mask —— */
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(12 + (seed % 21)),
                'e-2" numOctaves="1" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="3" result="bands"/>',
                /* —— displacement with animated strength —— */
                '<feDisplacementMap in="SourceGraphic" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distorted">',
                '<animate attributeName="scale" values="0;28;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                /* —— simple two-colour ghost edge —— */
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
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                _bokehLayer(x, y, size, seed * 2654435761, 4, 7, 20, 40, "b1"), // Large prime multipliers
                _bokehLayer(x, y, size, seed * 1073741827, 3, 9, 12, 25, "b2"), // for completely different seeds
                _bokehLayer(x, y, size, seed * 2147483647, 2, 11, 6, 15, "b3") // between layers
            );
    }

    function _bokehLayer(
        uint16 x,
        uint16 y,
        uint8 size,
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
                    seed + uint256(i) * 3571, // Much larger increment for better randomization
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
        uint8 size,
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
                Strings.toString(_calcPosY(y, s * 7919, size, spread)), // Completely different seed for Y
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
        uint8 size,
        uint8 spread
    ) internal pure returns (uint16) {
        // Slightly larger spread area
        uint256 halfBox = (uint256(size) * uint256(spread)) / 3; // Changed from /4 to /3
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
        uint8 size,
        uint8 spread
    ) internal pure returns (uint16) {
        // Slightly larger spread area
        uint256 halfBox = (uint256(size) * uint256(spread)) / 3; // Changed from /4 to /3
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
        uint8 size,
        bool pulse,
        bool glitch,
        string memory filterId
    ) internal pure returns (string memory) {
        uint8 sw = _strokeWidth(size);

        string memory glowFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Blur)"') // Use unique ID
            : ' filter="url(#blur)"';
        string memory crispFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Shift)"') // Use unique ID
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
        uint8 size,
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
        uint8 size,
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

    function _strokeWidth(uint8 size) internal pure returns (uint8) {
        if (size < 15) return 2;
        uint256 calc = (uint256(size) * 4) / 60;
        return uint8(calc < 2 ? 2 : calc > 15 ? 15 : calc);
    }
}
