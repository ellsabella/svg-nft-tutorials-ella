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
                "<g>",
                _createGlowLayer(x, y, size, animationPattern),
                _createCrispLayer(x, y, size, animationPattern),
                _createWhiteHotLayer(x, y, size, animationPattern),
                "</g>"
            );
    }

    // === GLOW LAYER (with blur filter) ===
    function _createGlowLayer(
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
            '" fill="none" stroke="#FF4444" stroke-width="6" filter="url(#blur)">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                "</circle>"
            );
    }

    // === CRISP LAYER (no filter) ===
    function _createCrispLayer(
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
            '" fill="none" stroke="#FF4444" stroke-width="6">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                "</circle>"
            );
    }

    // === WHITE HOT LAYER (animated opacity) ===
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
            '" fill="none" stroke="white" stroke-width="6" filter="url(#blur)" stroke-opacity="0.4">'
        );

        return
            string.concat(
                baseCircle,
                _getAnimationForPattern(x, y, size, pattern),
                '<animate attributeName="opacity" values="0;0.6;0" dur="4s" repeatCount="indefinite"/>',
                "</circle>"
            );
    }

    // === ANIMATION PATTERNS ===
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
//             '" fill="none" stroke="white" stroke-width="6" filter="url(#blur)" stroke-opacity="0.4">'
//         );

//         return
//             string.concat(
//                 baseCircle,
//                 _getAnimationForPattern(x, y, size, pattern),
//                 '<animate attributeName="opacity" values="0;0.6;0" dur="4s" repeatCount="indefinite"/>',
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
