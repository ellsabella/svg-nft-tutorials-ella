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
                string.concat(baseDefs, _createGlitchFilter(seed), "</defs>");
        } else {
            return string.concat(baseDefs, "</defs>");
        }
    }

    function _createGlitchFilter(
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="glitchShift" x="-20%" y="-20%" width="140%" height="140%">',
                '<feTurbulence type="fractalNoise" baseFrequency="0 0.9" numOctaves="2" seed="',
                Strings.toString(seed % 10000),
                '" result="t"/>',
                '<feColorMatrix in="t" type="matrix" values="1 0 0 0 -0.5 0 1 0 0 -0.5 0 0 1 0 -0.5 0 0 0 1 0" result="bars"/>',
                '<feComponentTransfer in="bars" result="mask">',
                '<feFuncR type="table" tableValues="0 1"/>',
                "</feComponentTransfer>",
                '<feDisplacementMap in="SourceGraphic" in2="mask" scale="18" xChannelSelector="R" yChannelSelector="R"/>',
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
                _bokehLayer(x, y, size, seed, 4, 7, 20, 40, "b1"),
                _bokehLayer(x, y, size, seed + 1111, 3, 9, 12, 25, "b2"),
                _bokehLayer(x, y, size, seed + 2222, 2, 11, 6, 15, "b3")
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
                    seed + uint256(i) * 1000,
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
                Strings.toString(_calcPosY(y, s >> 8, size, spread)),
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
        // Angle for X position (0-360°)
        uint256 angle = seed % 360;

        // Variable radius (20-100% of max distance)
        uint256 maxDist = uint256(size) * uint256(spread);
        uint256 radius = (((seed % 80) + 20) * maxDist) / 100;

        // Cos approximation for X: stronger at 0°/180°, weaker at 90°/270°
        uint256 xComponent;
        if (angle <= 90) {
            xComponent = (radius * (90 - angle)) / 90;
        } else if (angle <= 180) {
            xComponent = (radius * (angle - 90)) / 90;
        } else if (angle <= 270) {
            xComponent = (radius * (270 - angle)) / 90;
        } else {
            xComponent = (radius * (angle - 270)) / 90;
        }

        // Apply direction
        bool positiveX = (angle < 90) || (angle > 270);

        if (positiveX) {
            return center + uint16(xComponent);
        } else {
            return center > xComponent ? center - uint16(xComponent) : 0;
        }
    }

    function _calcPosY(
        uint16 center,
        uint256 seed,
        uint8 size,
        uint8 spread
    ) internal pure returns (uint16) {
        // Different angle for Y position (shifted by 127 for randomness)
        uint256 angle = (seed + 127) % 360;

        // Increased radius calculation for more vertical spread
        uint256 maxDist = (uint256(size) * uint256(spread) * 3) / 2; // 50% larger radius for Y
        uint256 radius = ((((seed >> 4) % 70) + 30) * maxDist) / 100; // 30-100% instead of 20-100%

        // Enhanced sin approximation for Y: stronger vertical component
        uint256 yComponent;
        if (angle <= 90) {
            yComponent = (radius * angle) / 90;
        } else if (angle <= 180) {
            yComponent = (radius * (180 - angle)) / 90;
        } else if (angle <= 270) {
            yComponent = (radius * (angle - 180)) / 90;
        } else {
            yComponent = (radius * (360 - angle)) / 90;
        }

        // FIXED: Correct direction logic for Y-axis
        // Positive Y (down) for angles 0-180, Negative Y (up) for angles 180-360
        bool moveDown = angle <= 180;

        if (moveDown) {
            return center + uint16(yComponent);
        } else {
            return center > yComponent ? center - uint16(yComponent) : 0;
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
        string memory filter = glitch
            ? ' filter="url(#glitchShift)"'
            : ' filter="url(#blur)"';

        return
            string.concat(
                _ring(x, y, size, sw <= 5 ? sw * 3 : 15, "0.5", filter),
                _ring(x, y, size, sw <= 5 ? sw * 2 : 10, "0.7", filter),
                _ring(
                    x,
                    y,
                    size,
                    sw,
                    "1",
                    glitch ? ' filter="url(#glitchShift)"' : ""
                ),
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
