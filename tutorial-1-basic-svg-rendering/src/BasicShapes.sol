// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IBasicShapes {
    function createCrossSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) external pure returns (string memory);
}

contract BasicShapes is IBasicShapes {
    function createCrossSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) external pure override returns (string memory) {
        // Ensure minimum size to prevent underflow
        if (size < 10) size = 10;

        // Pink crosses are always static (no pulsing white hot effects)
        return
            string.concat(
                "<g>",
                _createGlowLayer(x, y, size),
                _createCrispLayer(x, y, size),
                "</g>"
            );
    }

    // === GLOW LAYER (with blur filter) ===
    function _createGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);

        return
            string.concat(
                "<g>",
                _createSquareGlow(x, y, size, strokeWidth),
                _createDiagonal1Glow(x, y, size, strokeWidth),
                _createDiagonal2Glow(x, y, size, strokeWidth),
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

        return
            string.concat(
                "<g>",
                _createSquareCrisp(x, y, size, strokeWidth),
                _createDiagonal1Crisp(x, y, size),
                _createDiagonal2Crisp(x, y, size),
                "</g>"
            );
    }

    // === SQUARE COMPONENTS ===
    function _createSquareGlow(
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
                '" fill="none" stroke="#FF44FF" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>'
            );
    }

    function _createSquareCrisp(
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
                '" fill="none" stroke="#FF44FF" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    // === DIAGONAL COMPONENTS (GLOW) ===
    function _createDiagonal1Glow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<line x1="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y1="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" x2="',
                Strings.toString(x + halfSize),
                '" y2="',
                Strings.toString(y + halfSize),
                '" stroke="#FF44FF" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>'
            );
    }

    function _createDiagonal2Glow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<line x1="',
                Strings.toString(x + halfSize),
                '" y1="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" x2="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y2="',
                Strings.toString(y + halfSize),
                '" stroke="#FF44FF" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)"/>'
            );
    }

    // === DIAGONAL COMPONENTS (CRISP) ===
    function _createDiagonal1Crisp(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<line x1="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y1="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" x2="',
                Strings.toString(x + halfSize),
                '" y2="',
                Strings.toString(y + halfSize),
                '" stroke="#FF44FF" stroke-width="4"/>'
            );
    }

    function _createDiagonal2Crisp(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;
        return
            string.concat(
                '<line x1="',
                Strings.toString(x + halfSize),
                '" y1="',
                Strings.toString(y > halfSize ? y - halfSize : 0),
                '" x2="',
                Strings.toString(x > halfSize ? x - halfSize : 0),
                '" y2="',
                Strings.toString(y + halfSize),
                '" stroke="#FF44FF" stroke-width="4"/>'
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
