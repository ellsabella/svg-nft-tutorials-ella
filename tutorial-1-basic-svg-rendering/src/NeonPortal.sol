// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure returns (string memory);
}

contract NeonPortal is INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure override returns (string memory) {
        if (size < 20) size = 20;

        // 50% chance for glitch effect
        bool enableGlitch = (seed % 2) == 0;

        return
            string.concat(
                _createDefs(seed, enableGlitch),
                "<g>",
                _createBokeh(x, y, size, seed),
                _createRings(x, y, size, enablePulse, enableGlitch),
                "</g>"
            );
    }

    function _createDefs(
        uint256 seed,
        bool includeGlitch
    ) internal pure returns (string memory) {
        string memory baseDefs = string.concat(
            "<defs>",
            '<linearGradient id="ring"><stop offset="0" stop-color="#00FFFF"/><stop offset="1" stop-color="#FF00FF"/></linearGradient>',
            '<radialGradient id="b1"><stop offset="0" stop-color="#004080" stop-opacity="0.3"/><stop offset="0.6" stop-color="#002040" stop-opacity="0.15"/><stop offset="1" stop-color="#000000" stop-opacity="0.02"/></radialGradient>',
            '<radialGradient id="b2"><stop offset="0" stop-color="#800040" stop-opacity="0.25"/><stop offset="0.7" stop-color="#400020" stop-opacity="0.1"/><stop offset="1" stop-color="#000000" stop-opacity="0.01"/></radialGradient>',
            '<radialGradient id="b3"><stop offset="0" stop-color="#408080" stop-opacity="0.2"/><stop offset="0.8" stop-color="#204040" stop-opacity="0.08"/><stop offset="1" stop-color="#000000" stop-opacity="0.005"/></radialGradient>'
        );

        if (includeGlitch) {
            return
                string.concat(
                    baseDefs,
                    _createGlitchFilter(seed),
                    _createGlitchBlurFilter(seed), // Combined filter
                    "</defs>"
                );
        } else {
            return string.concat(baseDefs, "</defs>");
        }
    }

    /// @dev Pick a 3 – 6 s duration string from the seed
    function _animDur(uint256 seed) internal pure returns (string memory) {
        uint256 d = 3 + (seed % 4); // 3-6 s
        return string.concat(Strings.toString(d), "s");
    }

    function _createGlitchBlurFilter(
        uint256 seed
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="glitchBlur" x="-25%" y="-25%" width="150%" height="150%">',
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
        uint256 seed
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="glitchShift" x="-25%" y="-25%" width="150%" height="150%">',
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
        bool glitch
    ) internal pure returns (string memory) {
        uint8 sw = _strokeWidth(size);

        // Use combined filter for glitch (blur + glitch), or just blur for normal
        string memory glowFilter = glitch
            ? ' filter="url(#glitchBlur)"'
            : ' filter="url(#blur)"';
        string memory crispFilter = glitch ? ' filter="url(#glitchShift)"' : "";

        return
            string.concat(
                _ring(x, y, size, sw <= 5 ? sw * 3 : 15, "0.5", glowFilter),
                _ring(x, y, size, sw <= 5 ? sw * 2 : 10, "0.7", glowFilter),
                _ring(x, y, size, sw, "1", crispFilter),
                _highlight(x, y, size, pulse, glitch)
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
        bool glitch
    ) internal pure returns (string memory) {
        string memory base = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
            glitch ? ' filter="url(#glitchShift)"' : ""
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
