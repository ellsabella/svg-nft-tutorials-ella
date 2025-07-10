// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IRedCircles {
    function createAnimatedCircle(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        uint8 animationPattern
    ) external pure returns (string memory);
}

contract RedCircles is IRedCircles {
    function createAnimatedCircle(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        uint8 animationPattern
    ) external pure override returns (string memory) {
        // Ensure minimum size to prevent underflow
        if (size < 10) size = 10;

        return
            string.concat(
                _createRedGradientDefs(),
                "<g>",
                _createWideGlowLayer(x, y, size, animationPattern),
                _createMediumGlowLayer(x, y, size, animationPattern),
                _createCrispLayer(x, y, size, animationPattern),
                _createWhiteHotLayer(x, y, size, animationPattern),
                "</g>"
            );
    }

    // === GRADIENT DEFINITIONS ===
    function _createRedGradientDefs() internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Red to amber gradient
                '<linearGradient id="redAmber">',
                '<stop offset="0" stop-color="#FF4444"/>',
                '<stop offset="0.7" stop-color="#FF6644"/>',
                '<stop offset="1" stop-color="#FFAA44"/>',
                "</linearGradient>",
                "</defs>"
            );
    }

    // === WIDE GLOW LAYER (NEW) ===
    function _createWideGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 pattern
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        string memory baseCircle = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="url(#redAmber)" stroke-width="',
            Strings.toString(wideStrokeWidth),
            '" filter="url(#blur)" opacity="0.5">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                "</circle>"
            );
    }

    // === MEDIUM GLOW LAYER (RENAMED FROM GLOW) ===
    function _createMediumGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 pattern
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);
        uint8 mediumStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            mediumStrokeWidth = strokeWidth * 2;
        } else {
            mediumStrokeWidth = 10;
        }

        string memory baseCircle = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="url(#redAmber)" stroke-width="',
            Strings.toString(mediumStrokeWidth),
            '" filter="url(#blur)" opacity="0.7">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                "</circle>"
            );
    }

    // === CRISP LAYER (UPDATED) ===
    function _createCrispLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 pattern
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);

        string memory baseCircle = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="url(#redAmber)" stroke-width="',
            Strings.toString(strokeWidth),
            '">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                "</circle>"
            );
    }

    // === WHITE HOT LAYER (UPGRADED) ===
    function _createWhiteHotLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 pattern
    ) internal pure returns (string memory) {
        string memory baseCircle = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" filter="url(#blur)" opacity="0.9">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                // Upgraded animation: both opacity and stroke-width
                '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="4s" repeatCount="indefinite"/>',
                '<animate attributeName="stroke-width" values="1;3;1" dur="4s" repeatCount="indefinite"/>',
                "</circle>"
            );
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Same logic as NeonPortal - responsive stroke width
        if (size < 15) return 2;

        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;
        if (calculation > 10) return 10; // Cap for red circles
        return uint8(calculation);
    }

    // === ANIMATION PATTERNS (UNCHANGED) ===
    function _getAnimationForPattern(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 pattern
    ) internal pure returns (string memory) {
        if (pattern == 0) return _getLinearAnimation(x, y, size);
        if (pattern == 1) return _getOrbitAnimation(x, y, size);
        return _getPulseAnimation(size); // pattern == 2 or default
    }

    // PATTERN 0: Linear movement + size change
    function _getLinearAnimation(
        uint16 startX,
        uint16 startY,
        uint8 startSize
    ) internal pure returns (string memory) {
        uint16 targetX = startX > 720 ? 400 : 1000;
        uint16 targetY = startY > 720 ? 400 : 1000;
        uint8 maxSize = startSize + 30;

        return
            string.concat(
                '<animate attributeName="cx" values="',
                Strings.toString(startX),
                ";",
                Strings.toString(targetX),
                ";",
                Strings.toString(startX),
                '" dur="4s" repeatCount="indefinite"/>',
                '<animate attributeName="cy" values="',
                Strings.toString(startY),
                ";",
                Strings.toString(targetY),
                ";",
                Strings.toString(startY),
                '" dur="4s" repeatCount="indefinite"/>',
                '<animate attributeName="r" values="',
                Strings.toString(startSize),
                ";",
                Strings.toString(maxSize),
                ";",
                Strings.toString(startSize),
                '" dur="4s" repeatCount="indefinite"/>'
            );
    }

    // PATTERN 1: Orbital rotation + size change
    function _getOrbitAnimation(
        uint16 centerX,
        uint16 centerY,
        uint8 startSize
    ) internal pure returns (string memory) {
        uint8 maxSize = startSize + 30;

        return
            string.concat(
                '<animateTransform attributeName="transform" type="rotate" values="0 ',
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                ";360 ",
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                '" dur="4s" repeatCount="indefinite"/>',
                '<animate attributeName="r" values="',
                Strings.toString(startSize),
                ";",
                Strings.toString(maxSize),
                ";",
                Strings.toString(startSize),
                '" dur="4s" repeatCount="indefinite"/>'
            );
    }

    // PATTERN 2: Pulse (size change only)
    function _getPulseAnimation(
        uint8 startSize
    ) internal pure returns (string memory) {
        uint8 maxSize = startSize + 30;

        return
            string.concat(
                '<animate attributeName="r" values="',
                Strings.toString(startSize),
                ";",
                Strings.toString(maxSize),
                ";",
                Strings.toString(startSize),
                '" dur="4s" repeatCount="indefinite"/>'
            );
    }
}
// pragma solidity ^0.8.26;

// import {Random, RandomCtx} from "./utils/Random.sol";
// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// interface IRedCircles {
//     function createAnimatedCircle(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         uint8 animationPattern
//     ) external pure returns (string memory);
// }

// contract RedCircles is IRedCircles {
//     function createAnimatedCircle(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         uint8 animationPattern
//     ) external pure override returns (string memory) {
//         // Ensure minimum size to prevent underflow
//         if (size < 10) size = 10;

//         return
//             string.concat(
//                 "<g>",
//                 _createGlowLayer(x, y, size, animationPattern),
//                 _createCrispLayer(x, y, size, animationPattern),
//                 _createWhiteHotLayer(x, y, size, animationPattern),
//                 "</g>"
//             );
//     }

//     // === GLOW LAYER (with blur filter) ===
//     function _createGlowLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 pattern
//     ) internal pure returns (string memory) {
//         string memory baseCircle = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="#FF4444" stroke-width="6" filter="url(#blur)">'
//         );

//         return
//             string.concat(
//                 baseCircle,
//                 _getAnimationForPattern(x, y, size, pattern),
//                 "</circle>"
//             );
//     }

//     // === CRISP LAYER (no filter) ===
//     function _createCrispLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 pattern
//     ) internal pure returns (string memory) {
//         string memory baseCircle = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="#FF4444" stroke-width="6">'
//         );

//         return
//             string.concat(
//                 baseCircle,
//                 _getAnimationForPattern(x, y, size, pattern),
//                 "</circle>"
//             );
//     }

//     // === WHITE HOT LAYER (animated opacity) ===
//     function _createWhiteHotLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 pattern
//     ) internal pure returns (string memory) {
//         string memory baseCircle = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="white" stroke-width="3" filter="url(#blur)" stroke-opacity="0.7">'
//         );

//         return
//             string.concat(
//                 baseCircle,
//                 _getAnimationForPattern(x, y, size, pattern),
//                 '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="4s" repeatCount="indefinite"/>',
//                 "</circle>"
//             );
//     }

//     // === ANIMATION PATTERNS ===
//     function _getAnimationForPattern(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 pattern
//     ) internal pure returns (string memory) {
//         if (pattern == 0) return _getLinearAnimation(x, y, size);
//         if (pattern == 1) return _getOrbitAnimation(x, y, size);
//         return _getPulseAnimation(size); // pattern == 2 or default
//     }

//     // PATTERN 0: Linear movement + size change
//     function _getLinearAnimation(
//         uint16 startX,
//         uint16 startY,
//         uint8 startSize
//     ) internal pure returns (string memory) {
//         uint16 targetX = startX > 720 ? 400 : 1000;
//         uint16 targetY = startY > 720 ? 400 : 1000;
//         uint8 maxSize = startSize + 30;

//         return
//             string.concat(
//                 '<animate attributeName="cx" values="',
//                 Strings.toString(startX),
//                 ";",
//                 Strings.toString(targetX),
//                 ";",
//                 Strings.toString(startX),
//                 '" dur="4s" repeatCount="indefinite"/>',
//                 '<animate attributeName="cy" values="',
//                 Strings.toString(startY),
//                 ";",
//                 Strings.toString(targetY),
//                 ";",
//                 Strings.toString(startY),
//                 '" dur="4s" repeatCount="indefinite"/>',
//                 '<animate attributeName="r" values="',
//                 Strings.toString(startSize),
//                 ";",
//                 Strings.toString(maxSize),
//                 ";",
//                 Strings.toString(startSize),
//                 '" dur="4s" repeatCount="indefinite"/>'
//             );
//     }

//     // PATTERN 1: Orbital rotation + size change
//     function _getOrbitAnimation(
//         uint16 centerX,
//         uint16 centerY,
//         uint8 startSize
//     ) internal pure returns (string memory) {
//         uint8 maxSize = startSize + 30;

//         return
//             string.concat(
//                 '<animateTransform attributeName="transform" type="rotate" values="0 ',
//                 Strings.toString(centerX),
//                 " ",
//                 Strings.toString(centerY),
//                 ";360 ",
//                 Strings.toString(centerX),
//                 " ",
//                 Strings.toString(centerY),
//                 '" dur="4s" repeatCount="indefinite"/>',
//                 '<animate attributeName="r" values="',
//                 Strings.toString(startSize),
//                 ";",
//                 Strings.toString(maxSize),
//                 ";",
//                 Strings.toString(startSize),
//                 '" dur="4s" repeatCount="indefinite"/>'
//             );
//     }

//     // PATTERN 2: Pulse (size change only)
//     function _getPulseAnimation(
//         uint8 startSize
//     ) internal pure returns (string memory) {
//         uint8 maxSize = startSize + 30;

//         return
//             string.concat(
//                 '<animate attributeName="r" values="',
//                 Strings.toString(startSize),
//                 ";",
//                 Strings.toString(maxSize),
//                 ";",
//                 Strings.toString(startSize),
//                 '" dur="4s" repeatCount="indefinite"/>'
//             );
//     }
// }
