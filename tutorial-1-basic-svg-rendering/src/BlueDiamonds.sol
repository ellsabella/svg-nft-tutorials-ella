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

        uint8 strokeWidth = _getStrokeWidth(size);

        // Add back glow layer - using simplified version with stroke calculation
        string memory simpleGlow = string.concat(
            '<g transform="translate(',
            Strings.toString(x),
            ",",
            Strings.toString(y),
            ') rotate(0)">',
            '<polygon points="0,-',
            Strings.toString(size >= 4 ? size / 4 : 1),
            " ",
            Strings.toString(size >= 2 ? size / 2 : 1),
            ",0 0,",
            Strings.toString(size >= 4 ? size / 4 : 1),
            " -",
            Strings.toString(size >= 2 ? size / 2 : 1),
            ',0" fill="none" stroke="#44DDFF" stroke-width="',
            Strings.toString(strokeWidth),
            '" filter="url(#blur)"/>',
            "</g>"
        );

        string memory simpleCrisp = string.concat(
            '<g transform="translate(',
            Strings.toString(x),
            ",",
            Strings.toString(y),
            ') rotate(0)">',
            '<polygon points="0,-',
            Strings.toString(size >= 4 ? size / 4 : 1),
            " ",
            Strings.toString(size >= 2 ? size / 2 : 1),
            ",0 0,",
            Strings.toString(size >= 4 ? size / 4 : 1),
            " -",
            Strings.toString(size >= 2 ? size / 2 : 1),
            ',0" fill="none" stroke="#44DDFF" stroke-width="',
            Strings.toString(strokeWidth),
            '"/>',
            "</g>"
        );

        return string.concat("<g>", simpleGlow, simpleCrisp, "</g>");
    }

    // === GLOW LAYER (with blur filter) ===
    function _createGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        string memory rotation = _getRotation(seed);
        uint8 strokeWidth = _getStrokeWidth(size);

        // Ensure minimum values for polygon calculations
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
                ',0" fill="none" stroke="#44DDFF" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>',
                "</g>"
            );
    }

    // === CRISP LAYER (no filter) ===
    function _createCrispLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        string memory rotation = _getRotation(seed);
        uint8 strokeWidth = _getStrokeWidth(size);

        // Ensure minimum values for polygon calculations
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
                ',0" fill="none" stroke="#44DDFF" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>',
                "</g>"
            );
    }

    // === WHITE HOT LAYER (pulsing opacity) ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        string memory rotation = _getRotation(seed);
        uint8 strokeWidth = _getStrokeWidth(size);

        // Ensure minimum values for polygon calculations
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
                ',0" fill="none" stroke="white" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" stroke-opacity="0.4">',
                '<animate attributeName="opacity" values="0;0.6;0" dur="1s" repeatCount="indefinite"/>',
                "</polygon>",
                "</g>"
            );
    }

    // === UTILITY FUNCTIONS ===
    function _getRotation(uint256 seed) internal pure returns (string memory) {
        // Simple safe rotation - just return "0" for now to test
        uint256 safeSeed = seed % 61; // 0-60 range
        if (safeSeed <= 30) {
            return Strings.toString(safeSeed); // 0 to 30
        } else {
            return string.concat("-", Strings.toString(61 - safeSeed)); // -30 to -1
        }
    }

    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Ensure size is large enough to avoid division issues
        if (size < 15) return 2; // Minimum stroke width

        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;
        if (calculation > 6) return 6;
        return uint8(calculation);
    }

    function _intToString(int256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        bool negative = value < 0;
        uint256 temp;

        // Safe conversion to avoid underflow
        if (negative) {
            // Check for minimum int256 value to avoid overflow
            if (value == type(int256).min) {
                return
                    "-57896044618658097711785492504343953926634992332820282019728792003956564819968";
            }
            temp = uint256(-value);
        } else {
            temp = uint256(value);
        }

        uint256 digits;
        uint256 tempValue = temp;

        while (tempValue != 0) {
            digits++;
            tempValue /= 10;
        }

        bytes memory buffer = new bytes(negative ? digits + 1 : digits);
        uint256 index = buffer.length;

        while (temp != 0) {
            index--;
            buffer[index] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }

        if (negative) {
            buffer[0] = "-";
        }

        return string(buffer);
    }
}
