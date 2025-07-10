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
        // Larger minimum size for green squares with inner diamonds
        if (size < 20) size = 20;

        return
            string.concat(
                _createGreenGradientDefs(),
                "<g>",
                _createWideGlowLayer(x, y, size),
                _createMediumGlowLayer(x, y, size),
                _createCrispLayer(x, y, size),
                _createWhiteHotLayer(x, y, size, enablePulse),
                "</g>"
            );
    }

    // === GRADIENT DEFINITIONS ===
    function _createGreenGradientDefs() internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Radial gradient: bright green center to lime edges
                '<radialGradient id="greenLime" cx="0.5" cy="0.5">',
                '<stop offset="0" stop-color="#44DD44"/>',
                '<stop offset="0.7" stop-color="#66DD66"/>',
                '<stop offset="1" stop-color="#88FF88"/>',
                "</radialGradient>",
                "</defs>"
            );
    }

    // === WIDE GLOW LAYER ===
    function _createWideGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareWideGlow(x, y, size, wideStrokeWidth),
                _createInnerDiamondWideGlow(x, y, innerSize, wideStrokeWidth),
                "</g>"
            );
    }

    // === MEDIUM GLOW LAYER ===
    function _createMediumGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 mediumStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            mediumStrokeWidth = strokeWidth * 2;
        } else {
            mediumStrokeWidth = 10;
        }

        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareMediumGlow(x, y, size, mediumStrokeWidth),
                _createInnerDiamondMediumGlow(
                    x,
                    y,
                    innerSize,
                    mediumStrokeWidth
                ),
                "</g>"
            );
    }

    // === CRISP LAYER ===
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

    // === WHITE HOT LAYER ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        uint8 innerSize = (size * 2) / 3;

        return
            string.concat(
                "<g>",
                _createOuterSquareWhiteHot(x, y, size, enablePulse),
                _createInnerDiamondWhiteHot(x, y, innerSize, enablePulse),
                "</g>"
            );
    }

    // === OUTER SQUARE COMPONENTS ===
    function _createOuterSquareWideGlow(
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.4"/>'
            );
    }

    function _createOuterSquareMediumGlow(
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>'
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    function _createOuterSquareWhiteHot(
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
            '" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.7"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseRect,
                    ">",
                    '<animate attributeName="opacity" values="0.3;0.7;0.3" dur="3s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="3s" repeatCount="indefinite"/>',
                    "</rect>"
                );
        } else {
            return string.concat(baseRect, "/>");
        }
    }

    // === INNER DIAMOND COMPONENTS ===
    function _createInnerDiamondWideGlow(
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.4"/>',
                "</g>"
            );
    }

    function _createInnerDiamondMediumGlow(
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#blur)" opacity="0.6"/>',
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
                '" fill="none" stroke="url(#greenLime)" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>',
                "</g>"
            );
    }

    function _createInnerDiamondWhiteHot(
        uint16 x,
        uint16 y,
        uint8 innerSize,
        bool enablePulse
    ) internal pure returns (string memory) {
        string memory baseDiamond = string.concat(
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
            '" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.7"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseDiamond,
                    ">",
                    '<animate attributeName="opacity" values="0.3;0.7;0.3" dur="3s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="0.5;2;0.5" dur="3s" repeatCount="indefinite"/>',
                    "</rect>",
                    "</g>"
                );
        } else {
            return string.concat(baseDiamond, "/>", "</g>");
        }
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Responsive stroke width - slightly thicker for larger squares
        if (size < 20) return 3;
        if (size < 40) return 4;
        if (size < 60) return 5;
        if (size < 80) return 6;
        return 8;
    }
}
