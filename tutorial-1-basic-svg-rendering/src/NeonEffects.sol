// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface INeonEffects {
    enum GlowIntensity {
        STATIC, // Non-pulsing shapes
        PULSE_SLOW, // 3 second pulse
        PULSE_FAST, // 1 second pulse
        PULSE_EXTREME // 2 second pulse
    }

    function createEnhancedFilters() external pure returns (string memory);

    function isPulsing(GlowIntensity intensity) external pure returns (bool);

    // UPDATED: Add size parameter
    function createWhiteHotStroke(
        uint256 shapeType,
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 seed,
        uint256 size
    ) external pure returns (string memory);
}

contract NeonEffects is INeonEffects {
    function createEnhancedFilters()
        external
        pure
        override
        returns (string memory)
    {
        return
            string.concat(
                "<defs>",
                _createOriginalBlurFilter(), // Only filter we actually use
                "</defs>"
            );
    }

    function _createOriginalBlurFilter() internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="blur" filterUnits="userSpaceOnUse" ',
                'x="-720" y="-720" width="2160" height="2160">',
                // Multi-layer base glow
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="tight"/>',
                '<feColorMatrix in="tight" type="matrix" values="',
                '6 0 0 0 0 0 6 0 0 0 0 0 6 0 0 0 0 0 1.0 0" result="tightColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="15" result="medium"/>',
                '<feColorMatrix in="medium" type="matrix" values="',
                '4 0 0 0 0 0 4 0 0 0 0 0 4 0 0 0 0 0 0.8 0" result="mediumColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="35" result="wide"/>',
                '<feColorMatrix in="wide" type="matrix" values="',
                '2 0 0 0 0 0 2 0 0 0 0 0 2 0 0 0 0 0 0.6 0" result="wideColored"/>',
                "<feMerge>",
                '<feMergeNode in="wideColored"/>',
                '<feMergeNode in="mediumColored"/>',
                '<feMergeNode in="tightColored"/>',
                '<feMergeNode in="SourceGraphic"/>',
                "</feMerge>",
                "</filter>"
            );
    }

    function isPulsing(
        GlowIntensity intensity
    ) external pure override returns (bool) {
        return
            intensity == GlowIntensity.PULSE_SLOW ||
            intensity == GlowIntensity.PULSE_FAST ||
            intensity == GlowIntensity.PULSE_EXTREME;
    }

    // UPDATED: Now accepts size parameter
    function createWhiteHotStroke(
        uint256 shapeType,
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 seed,
        uint256 size
    ) external pure override returns (string memory) {
        if (shapeType == 0) return _createWhiteHotCircle(x, y, intensity, size);
        if (shapeType == 1)
            return _createWhiteHotDiamond(x, y, intensity, seed, size);
        if (shapeType == 2)
            return _createWhiteHotSquareDiamond(x, y, intensity, size);
        return _createWhiteHotCrossSquare(x, y, intensity, size);
    }

    function _createWhiteHotCircle(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(x),
                    '" cy="',
                    Strings.toString(y),
                    '" r="',
                    Strings.toString(size), // Use dynamic size
                    '" fill="none" stroke="white" stroke-width="',
                    Strings.toString(_getStrokeWidth(size)),
                    '" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</circle>"
                )
            );
    }

    function _createWhiteHotDiamond(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 seed,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);
        return
            string(
                abi.encodePacked(
                    '<g transform="translate(',
                    Strings.toString(x),
                    ",",
                    Strings.toString(y),
                    ") rotate(",
                    _intToString(int256((seed % 61)) - 30),
                    ')">',
                    '<polygon points="0,-',
                    Strings.toString(size / 4), // Dynamic quarter size
                    " ",
                    Strings.toString(size / 2), // Dynamic half size
                    ",0 0,",
                    Strings.toString(size / 4),
                    " -",
                    Strings.toString(size / 2),
                    ',0" fill="none" stroke="white" stroke-width="',
                    Strings.toString(_getStrokeWidth(size)),
                    '" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</polygon></g>"
                )
            );
    }

    function _createWhiteHotSquareDiamond(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);

        string memory outerSquare = string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString(x - size / 2), // Dynamic half size
                '" y="',
                Strings.toString(y - size / 2),
                '" width="',
                Strings.toString(size), // Dynamic size
                '" height="',
                Strings.toString(size),
                '" fill="none" stroke="white" stroke-width="',
                Strings.toString(_getStrokeWidth(size)),
                '" filter="url(#blur)" stroke-opacity="0.4">',
                '<animate attributeName="opacity" values="0;0.6;0" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</rect>"
            )
        );

        uint256 innerSize = (size * 2) / 3; // Dynamic inner size
        string memory innerDiamond = string(
            abi.encodePacked(
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
                Strings.toString(_getStrokeWidth(size)),
                '" filter="url(#blur)" stroke-opacity="0.4">',
                '<animate attributeName="opacity" values="0;0.6;0" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</rect></g>"
            )
        );

        return
            string(abi.encodePacked("<g>", outerSquare, innerDiamond, "</g>"));
    }

    function _createWhiteHotCrossSquare(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _createWhiteSquare(x, y, intensity, size),
                    _createWhiteDiagonals(x, y, intensity, size)
                )
            );
    }

    function _createWhiteSquare(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);
        return
            string(
                abi.encodePacked(
                    '<rect x="',
                    Strings.toString(x - size / 2),
                    '" y="',
                    Strings.toString(y - size / 2),
                    '" width="',
                    Strings.toString(size),
                    '" height="',
                    Strings.toString(size),
                    '" fill="none" stroke="white" stroke-width="4" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</rect>"
                )
            );
    }

    function _createWhiteDiagonals(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _createWhiteDiagonal1(x, y, intensity, size),
                    _createWhiteDiagonal2(x, y, intensity, size)
                )
            );
    }

    function _createWhiteDiagonal1(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);
        return
            string(
                abi.encodePacked(
                    '<line x1="',
                    Strings.toString(x - size / 2),
                    '" y1="',
                    Strings.toString(y - size / 2),
                    '" x2="',
                    Strings.toString(x + size / 2),
                    '" y2="',
                    Strings.toString(y + size / 2),
                    '" stroke="white" stroke-width="4" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</line>"
                )
            );
    }

    function _createWhiteDiagonal2(
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 size
    ) internal pure returns (string memory) {
        string memory dur = _getDuration(intensity);
        return
            string(
                abi.encodePacked(
                    '<line x1="',
                    Strings.toString(x + size / 2),
                    '" y1="',
                    Strings.toString(y - size / 2),
                    '" x2="',
                    Strings.toString(x - size / 2),
                    '" y2="',
                    Strings.toString(y + size / 2),
                    '" stroke="white" stroke-width="4" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</line>"
                )
            );
    }

    function _getStrokeWidth(uint256 size) internal pure returns (uint256) {
        // Scale stroke width with size: 30-80 -> 3-8
        uint256 stroke = (size * 8) / 80;
        if (stroke < 3) return 3;
        if (stroke > 8) return 8;
        return stroke;
    }

    function _getDuration(
        GlowIntensity intensity
    ) internal pure returns (string memory) {
        if (intensity == GlowIntensity.PULSE_FAST) return "1";
        if (intensity == GlowIntensity.PULSE_SLOW) return "3";
        return "2"; // PULSE_EXTREME default
    }

    function _intToString(int256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        bool negative = value < 0;
        if (negative) value = -value;

        uint256 temp = uint256(value);
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
