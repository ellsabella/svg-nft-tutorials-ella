// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IAnimations {
    struct AnimationParams {
        uint16 startX;
        uint16 startY;
        uint16 targetX;
        uint16 targetY;
        uint8 startSize;
        uint8 maxSize;
        uint8 duration;
        uint8 delay;
        uint8 pattern;
    }

    function createRedCircleAnimation(
        uint256 tokenId,
        uint256 circleIndex,
        uint16 startX,
        uint16 startY,
        uint8 startSize
    ) external pure returns (AnimationParams memory);

    function generateAnimatedCircle(
        uint16 x,
        uint16 y,
        uint8 size,
        string memory color,
        AnimationParams memory params
    ) external pure returns (string memory);
}

contract Animations is IAnimations {
    function createRedCircleAnimation(
        uint256 tokenId,
        uint256 circleIndex,
        uint16 startX,
        uint16 startY,
        uint8 startSize
    ) external pure override returns (AnimationParams memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + circleIndex + 999);

        uint8 pattern = uint8(Random.randInt(ctx) % 3);

        return
            AnimationParams({
                startX: startX,
                startY: startY,
                targetX: _generateTargetX(startX, pattern),
                targetY: _generateTargetY(startY, pattern),
                startSize: startSize,
                maxSize: startSize + 30,
                duration: 4,
                delay: uint8(circleIndex),
                pattern: pattern
            });
    }

    // ULTRA SIMPLIFIED: Generate complete animated circle WITH GLOW AND WHITE HOT STROKE
    function generateAnimatedCircle(
        uint16 x,
        uint16 y,
        uint8 size,
        string memory color,
        AnimationParams memory params
    ) external pure override returns (string memory) {
        // Create base circle (no filter)
        string memory baseCircle;
        if (params.pattern == 0) {
            baseCircle = _createLinearCircle(params);
        } else if (params.pattern == 1) {
            baseCircle = _createOrbitCircle(params);
        } else {
            baseCircle = _createPulseCircle(params);
        }

        // Create glowing version (with blur filter)
        string memory glowCircle;
        if (params.pattern == 0) {
            glowCircle = _createLinearCircleGlow(params);
        } else if (params.pattern == 1) {
            glowCircle = _createOrbitCircleGlow(params);
        } else {
            glowCircle = _createPulseCircleGlow(params);
        }

        // Create white hot stroke version
        string memory whiteHotCircle = _createWhiteHotVersion(params);

        return
            string(
                abi.encodePacked(
                    "<g>",
                    glowCircle, // Glow layer first
                    baseCircle, // Crisp layer on top
                    whiteHotCircle, // White hot stroke overlay
                    "</g>"
                )
            );
    }

    // Add glow versions of each pattern
    function _createLinearCircleGlow(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="#FF4444" stroke-width="6" filter="url(#blur)">',
                    _getLinearAnimations(params),
                    "</circle>"
                )
            );
    }

    function _createOrbitCircleGlow(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="#FF4444" stroke-width="6" filter="url(#blur)">',
                    _getOrbitAnimation(params),
                    _getSizeAnimation(params),
                    "</circle>"
                )
            );
    }

    function _createPulseCircleGlow(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="#FF4444" stroke-width="6" filter="url(#blur)">',
                    _getSizeAnimation(params),
                    "</circle>"
                )
            );
    }

    // Create white hot stroke version that matches the base animation
    function _createWhiteHotVersion(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        if (params.pattern == 0) {
            return _createWhiteHotLinear(params);
        } else if (params.pattern == 1) {
            return _createWhiteHotOrbit(params);
        } else {
            return _createWhiteHotPulse(params);
        }
    }

    function _createWhiteHotLinear(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="white" stroke-width="6" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="cx" values="',
                    Strings.toString(params.startX),
                    ";",
                    Strings.toString(params.targetX),
                    ";",
                    Strings.toString(params.startX),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="cy" values="',
                    Strings.toString(params.startY),
                    ";",
                    Strings.toString(params.targetY),
                    ";",
                    Strings.toString(params.startY),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="r" values="',
                    Strings.toString(params.startSize),
                    ";",
                    Strings.toString(params.maxSize),
                    ";",
                    Strings.toString(params.startSize),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                )
            );
    }

    function _createWhiteHotOrbit(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="white" stroke-width="6" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animateTransform attributeName="transform" type="rotate" values="0 ',
                    Strings.toString(params.startX),
                    " ",
                    Strings.toString(params.startY),
                    ";360 ",
                    Strings.toString(params.startX),
                    " ",
                    Strings.toString(params.startY),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="r" values="',
                    Strings.toString(params.startSize),
                    ";",
                    Strings.toString(params.maxSize),
                    ";",
                    Strings.toString(params.startSize),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                )
            );
    }

    function _createWhiteHotPulse(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="white" stroke-width="6" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="r" values="',
                    Strings.toString(params.startSize),
                    ";",
                    Strings.toString(params.maxSize),
                    ";",
                    Strings.toString(params.startSize),
                    '" dur="4s" repeatCount="indefinite"/>',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                )
            );
    }

    // PATTERN 0: Split into parts to avoid stack depth
    function _createLinearCircle(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _getCircleStart(params),
                    _getLinearAnimations(params),
                    "</circle>"
                )
            );
    }

    function _getCircleStart(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.startX),
                    '" cy="',
                    Strings.toString(params.startY),
                    '" r="',
                    Strings.toString(params.startSize),
                    '" fill="none" stroke="#FF4444" stroke-width="6">' // NO FILTER - crisp version
                )
            );
    }

    function _getLinearAnimations(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<animate attributeName="cx" values="',
                    Strings.toString(params.startX),
                    ";",
                    Strings.toString(params.targetX),
                    ";",
                    Strings.toString(params.startX),
                    '" dur="4s" repeatCount="indefinite"/>',
                    _getPositionYAnimation(params),
                    _getSizeAnimation(params)
                )
            );
    }

    function _getPositionYAnimation(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<animate attributeName="cy" values="',
                    Strings.toString(params.startY),
                    ";",
                    Strings.toString(params.targetY),
                    ";",
                    Strings.toString(params.startY),
                    '" dur="4s" repeatCount="indefinite"/>'
                )
            );
    }

    function _getSizeAnimation(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<animate attributeName="r" values="',
                    Strings.toString(params.startSize),
                    ";",
                    Strings.toString(params.maxSize),
                    ";",
                    Strings.toString(params.startSize),
                    '" dur="4s" repeatCount="indefinite"/>'
                )
            );
    }

    // PATTERN 1: Orbital - simplified
    function _createOrbitCircle(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _getCircleStart(params),
                    _getOrbitAnimation(params),
                    _getSizeAnimation(params),
                    "</circle>"
                )
            );
    }

    function _getOrbitAnimation(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<animateTransform attributeName="transform" type="rotate" values="0 ',
                    Strings.toString(params.startX),
                    " ",
                    Strings.toString(params.startY),
                    ";360 ",
                    Strings.toString(params.startX),
                    " ",
                    Strings.toString(params.startY),
                    '" dur="4s" repeatCount="indefinite"/>'
                )
            );
    }

    // PATTERN 2: Pulse - simplest
    function _createPulseCircle(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _getCircleStart(params),
                    _getSizeAnimation(params),
                    "</circle>"
                )
            );
    }

    // Minimal helper functions
    function _generateTargetX(
        uint16 startX,
        uint8 pattern
    ) internal pure returns (uint16) {
        if (pattern == 0) return startX > 720 ? 400 : 1000;
        if (pattern == 1) return startX + 100;
        return startX;
    }

    function _generateTargetY(
        uint16 startY,
        uint8 pattern
    ) internal pure returns (uint16) {
        if (pattern == 0) return startY > 720 ? 400 : 1000;
        if (pattern == 1) return startY + 100;
        return startY;
    }
}
