// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IBasicShapes {
    function createCrossSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        string memory color
    ) external pure returns (string memory);
}

contract BasicShapes is IBasicShapes {
    function createCrossSquare(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        string memory color
    ) external pure override returns (string memory) {
        // Larger minimum size for cross squares
        if (size < 15) size = 15;

        // Cross squares have random pulsing based on seed
        bool enablePulse = (seed % 4) == 0; // 25% chance

        return
            string.concat(
                "<g>",
                _createWideGlowLayer(x, y, size, color),
                _createMediumGlowLayer(x, y, size, color),
                _createCrispLayer(x, y, size, color),
                _createWhiteHotLayer(x, y, size, enablePulse),
                "</g>"
            );
    }

    // === WIDE GLOW LAYER ===
    function _createWideGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        string memory color
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        return
            string.concat(
                "<g>",
                _createSquareWideGlow(x, y, size, wideStrokeWidth, color),
                _createDiagonal1WideGlow(x, y, size, wideStrokeWidth, color),
                _createDiagonal2WideGlow(x, y, size, wideStrokeWidth, color),
                "</g>"
            );
    }

    // === MEDIUM GLOW LAYER ===
    function _createMediumGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        string memory color
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 mediumStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            mediumStrokeWidth = strokeWidth * 2;
        } else {
            mediumStrokeWidth = 10;
        }

        return
            string.concat(
                "<g>",
                _createSquareMediumGlow(x, y, size, mediumStrokeWidth, color),
                _createDiagonal1MediumGlow(
                    x,
                    y,
                    size,
                    mediumStrokeWidth,
                    color
                ),
                _createDiagonal2MediumGlow(
                    x,
                    y,
                    size,
                    mediumStrokeWidth,
                    color
                ),
                "</g>"
            );
    }

    // === CRISP LAYER ===
    function _createCrispLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        string memory color
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);

        return
            string.concat(
                "<g>",
                _createSquareCrisp(x, y, size, strokeWidth, color),
                _createDiagonal1Crisp(x, y, size, strokeWidth, color),
                _createDiagonal2Crisp(x, y, size, strokeWidth, color),
                "</g>"
            );
    }

    // === WHITE HOT LAYER ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<g>",
                _createSquareWhiteHot(x, y, size, enablePulse),
                _createDiagonal1WhiteHot(x, y, size, enablePulse),
                _createDiagonal2WhiteHot(x, y, size, enablePulse),
                "</g>"
            );
    }

    // === SQUARE COMPONENTS ===
    function _createSquareWideGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" fill="none" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.5"/>'
            );
    }

    function _createSquareMediumGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" fill="none" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>'
            );
    }

    function _createSquareCrisp(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" fill="none" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    function _createSquareWhiteHot(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;

        string memory baseRect = string.concat(
            '<rect x="',
            Strings.toString(x > halfSize ? x - halfSize : 0),
            '" y="',
            Strings.toString(y > halfSize ? y - halfSize : 0),
            '" width="',
            Strings.toString(size),
            '" height="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseRect,
                    ">",
                    // ANIMATIONS COMMENTED OUT
                    // '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2.5s" repeatCount="indefinite"/>',
                    // '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="2.5s" repeatCount="indefinite"/>',
                    "</rect>"
                );
        } else {
            return string.concat(baseRect, "/>");
        }
    }

    // === DIAGONAL COMPONENTS ===
    function _createDiagonal1WideGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.5"/>'
            );
    }

    function _createDiagonal2WideGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.5"/>'
            );
    }

    function _createDiagonal1MediumGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>'
            );
    }

    function _createDiagonal2MediumGlow(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>'
            );
    }

    function _createDiagonal1Crisp(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    function _createDiagonal2Crisp(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth,
        string memory color
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
                '" stroke="',
                color,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    function _createDiagonal1WhiteHot(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;

        string memory baseLine = string.concat(
            '<line x1="',
            Strings.toString(x > halfSize ? x - halfSize : 0),
            '" y1="',
            Strings.toString(y > halfSize ? y - halfSize : 0),
            '" x2="',
            Strings.toString(x + halfSize),
            '" y2="',
            Strings.toString(y + halfSize),
            '" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseLine,
                    ">",
                    // ANIMATIONS COMMENTED OUT
                    // '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2.5s" repeatCount="indefinite"/>',
                    // '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="2.5s" repeatCount="indefinite"/>',
                    "</line>"
                );
        } else {
            return string.concat(baseLine, "/>");
        }
    }

    function _createDiagonal2WhiteHot(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        uint16 halfSize = size / 2;

        string memory baseLine = string.concat(
            '<line x1="',
            Strings.toString(x + halfSize),
            '" y1="',
            Strings.toString(y > halfSize ? y - halfSize : 0),
            '" x2="',
            Strings.toString(x > halfSize ? x - halfSize : 0),
            '" y2="',
            Strings.toString(y + halfSize),
            '" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseLine,
                    ">",
                    // ANIMATIONS COMMENTED OUT
                    // '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2.5s" repeatCount="indefinite"/>',
                    // '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="2.5s" repeatCount="indefinite"/>',
                    "</line>"
                );
        } else {
            return string.concat(baseLine, "/>");
        }
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Responsive stroke width for cross squares
        if (size < 20) return 2;
        if (size < 40) return 3;
        if (size < 60) return 4;
        if (size < 80) return 5;
        return 6;
    }
}
