// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IBlueDiamonds {
    function createAnimatedDiamond(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure returns (string memory);
}

contract BlueDiamonds is IBlueDiamonds {
    function createAnimatedDiamond(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure override returns (string memory) {
        // Ensure minimum size to prevent underflow
        if (size < 10) size = 10;

        return
            string.concat(
                _createBlueGradientDefs(),
                "<g>",
                _createWideGlowLayer(x, y, size, seed),
                _createMediumGlowLayer(x, y, size, seed),
                _createCrispLayer(x, y, size, seed),
                _createWhiteHotLayer(x, y, size, seed, enablePulse),
                "</g>"
            );
    }

    // === GRADIENT DEFINITIONS ===
    function _createBlueGradientDefs() internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Radial gradient: mid-blue center to cyan edges
                '<radialGradient id="blueCyan" cx="0.5" cy="0.5">',
                '<stop offset="0" stop-color="#66DDFF"/>',
                '<stop offset="0.7" stop-color="#66AADD"/>',
                '<stop offset="1" stop-color="#66DDFF"/>',
                "</radialGradient>",
                "</defs>"
            );
    }

    // === WIDE GLOW LAYER ===
    function _createWideGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        string memory rotation = _getRotation(seed);
        uint8 quarter = size >= 4 ? size / 4 : 1;
        uint8 half = size >= 2 ? size / 2 : 1;

        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ") rotate(",
                rotation,
                ')">',
                '<polygon points="0,-',
                Strings.toString(quarter),
                " ",
                Strings.toString(half),
                ",0 0,",
                Strings.toString(quarter),
                " -",
                Strings.toString(half),
                ',0" fill="none" stroke="url(#blueCyan)" stroke-width="',
                Strings.toString(wideStrokeWidth),
                '" filter="url(#blur)" opacity="0.5"/>',
                "</g>"
            );
    }

    // === MEDIUM GLOW LAYER ===
    function _createMediumGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 mediumStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            mediumStrokeWidth = strokeWidth * 2;
        } else {
            mediumStrokeWidth = 10;
        }

        string memory rotation = _getRotation(seed);
        uint8 quarter = size >= 4 ? size / 4 : 1;
        uint8 half = size >= 2 ? size / 2 : 1;

        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ") rotate(",
                rotation,
                ')">',
                '<polygon points="0,-',
                Strings.toString(quarter),
                " ",
                Strings.toString(half),
                ",0 0,",
                Strings.toString(quarter),
                " -",
                Strings.toString(half),
                ',0" fill="none" stroke="url(#blueCyan)" stroke-width="',
                Strings.toString(mediumStrokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>',
                "</g>"
            );
    }

    // === CRISP LAYER ===
    function _createCrispLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        string memory rotation = _getRotation(seed);
        uint8 quarter = size >= 4 ? size / 4 : 1;
        uint8 half = size >= 2 ? size / 2 : 1;

        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ") rotate(",
                rotation,
                ')">',
                '<polygon points="0,-',
                Strings.toString(quarter),
                " ",
                Strings.toString(half),
                ",0 0,",
                Strings.toString(quarter),
                " -",
                Strings.toString(half),
                ',0" fill="none" stroke="url(#blueCyan)" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>',
                "</g>"
            );
    }

    // === WHITE HOT LAYER ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) internal pure returns (string memory) {
        string memory rotation = _getRotation(seed);
        uint8 quarter = size >= 4 ? size / 4 : 1;
        uint8 half = size >= 2 ? size / 2 : 1;

        string memory baseDiamond = string.concat(
            '<g transform="translate(',
            Strings.toString(x),
            ",",
            Strings.toString(y),
            ") rotate(",
            rotation,
            ')">',
            '<polygon points="0,-',
            Strings.toString(quarter),
            " ",
            Strings.toString(half),
            ",0 0,",
            Strings.toString(quarter),
            " -",
            Strings.toString(half),
            ',0" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseDiamond,
                    ">",
                    '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="3s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="3s" repeatCount="indefinite"/>',
                    "</polygon>",
                    "</g>"
                );
        } else {
            return string.concat(baseDiamond, "/>", "</g>");
        }
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Same responsive logic as upgraded red circles
        if (size < 15) return 2;

        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;
        if (calculation > 10) return 10;
        return uint8(calculation);
    }

    function _getRotation(uint256 seed) internal pure returns (string memory) {
        // Safe rotation calculation
        uint256 safeSeed = seed % 61; // 0-60 range
        if (safeSeed <= 30) {
            return Strings.toString(safeSeed); // 0 to 30
        } else {
            return string.concat("-", Strings.toString(61 - safeSeed)); // -30 to -1
        }
    }
}
