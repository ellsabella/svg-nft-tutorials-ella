// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IGreenSquares {
    function createAnimatedSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure returns (string memory);
}

contract GreenSquares is IGreenSquares {
    function createAnimatedSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure override returns (string memory) {
        // Ensure minimum size to prevent underflow
        if (size < 10) size = 10;

        if (enablePulse) {
            return
                string.concat(
                    "<g>",
                    _createGlowLayer(x, y, size),
                    _createCrispLayer(x, y, size),
                    _createWhiteHotLayer(x, y, size),
                    "</g>"
                );
        } else {
            return
                string.concat(
                    "<g>",
                    _createGlowLayer(x, y, size),
                    _createCrispLayer(x, y, size),
                    "</g>"
                );
        }
    }

    // === GLOW LAYER (with blur filter) ===
    function _createGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareGlow(x, y, size, strokeWidth),
                _createInnerDiamondGlow(x, y, innerSize, strokeWidth),
                "</g>"
            );
    }

    // === CRISP LAYER (no filter) ===
    function _createCrispLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareCrisp(x, y, size, strokeWidth),
                _createInnerDiamondCrisp(x, y, innerSize, strokeWidth),
                "</g>"
            );
    }

    // === WHITE HOT LAYER (pulsing opacity) ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareWhiteHot(x, y, size, strokeWidth),
                _createInnerDiamondWhiteHot(x, y, innerSize, strokeWidth),
                "</g>"
            );
    }

    // === OUTER SQUARE COMPONENTS ===
    function _createOuterSquareGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<rect x="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" width="',
                Strings.toString(size),
                '" height="',
                Strings.toString(size),
                '" fill="none" stroke="#44FF44" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>'
            );
    }

    function _createOuterSquareCrisp(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<rect x="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" width="',
                Strings.toString(size),
                '" height="',
                Strings.toString(size),
                '" fill="none" stroke="#44FF44" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    function _createOuterSquareWhiteHot(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<rect x="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" width="',
                Strings.toString(size),
                '" height="',
                Strings.toString(size),
                '" fill="none" stroke="white" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" stroke-opacity="0.4">',
                '<animate attributeName="opacity" values="0;0.6;0" dur="3s" repeatCount="indefinite"/>',
                "</rect>"
            );
    }

    // === INNER DIAMOND COMPONENTS ===
    function _createInnerDiamondGlow(
        uint16 x,
        uint16 y,
        uint8 innerSize,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ') rotate(45)">',
                '<rect x="-',
                Strings.toString(innerSize / 2),
                '" y="-',
                Strings.toString(innerSize / 2),
                '" width="',
                Strings.toString(innerSize),
                '" height="',
                Strings.toString(innerSize),
                '" fill="none" stroke="#44FF44" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>',
                "</g>"
            );
    }

    function _createInnerDiamondCrisp(
        uint16 x,
        uint16 y,
        uint8 innerSize,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ') rotate(45)">',
                '<rect x="-',
                Strings.toString(innerSize / 2),
                '" y="-',
                Strings.toString(innerSize / 2),
                '" width="',
                Strings.toString(innerSize),
                '" height="',
                Strings.toString(innerSize),
                '" fill="none" stroke="#44FF44" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>',
                "</g>"
            );
    }

    function _createInnerDiamondWhiteHot(
        uint16 x,
        uint16 y,
        uint8 innerSize,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ') rotate(45)">',
                '<rect x="-',
                Strings.toString(innerSize / 2),
                '" y="-',
                Strings.toString(innerSize / 2),
                '" width="',
                Strings.toString(innerSize),
                '" height="',
                Strings.toString(innerSize),
                '" fill="none" stroke="white" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" stroke-opacity="0.4">',
                '<animate attributeName="opacity" values="0;0.6;0" dur="3s" repeatCount="indefinite"/>',
                "</rect>",
                "</g>"
            );
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Ensure size is large enough to avoid division issues
        if (size < 15) return 2; // Minimum stroke width

        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;
        if (calculation > 6) return 6;
        return uint8(calculation);
    }
}
