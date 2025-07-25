// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IVisualCore} from "./VisualCore.sol";

interface INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse
    ) external view returns (string memory);

    function createAnimatedNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) external view returns (string memory);
}

contract NeonPortal is INeonPortal {
    IVisualCore public immutable visualCore;

    constructor(address core) {
        visualCore = IVisualCore(core);
    }

    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse
    ) external view override returns (string memory) {
        return
            _createPortalInternal(x, y, size, seed, enablePulse, false, x, y);
    }

    function createAnimatedNeonPortal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) external view override returns (string memory) {
        return
            _createPortalInternal(
                x,
                y,
                size,
                seed,
                false,
                false, // No pulse in this case
                // enablePulse,
                // enableMovement,
                centerX,
                centerY
            );
    }

    function _createPortalInternal(
        uint16 x,
        uint16 y,
        uint16 size,
        uint256 seed,
        bool enablePulse,
        bool enableMovement,
        uint16 centerX,
        uint16 centerY
    ) internal view returns (string memory) {
        if (size < 20) size = 20;
        bool enableGlitch = (seed % 2) == 0;

        string memory filterId = string.concat(
            "glitch",
            Strings.toString(seed % 10000)
        );

        string memory content = string.concat(
            enableGlitch
                ? string.concat(
                    "<defs>",
                    _createGlitchFilter(seed, filterId),
                    _createGlitchBlurFilter(seed, filterId),
                    "</defs>"
                )
                : "",
            _createRings(x, y, size, enablePulse, enableGlitch, filterId)
        );

        if (enableMovement) {
            if (centerX == x && centerY == y) {
                return _wrapWithGrowShrinkAnimation(content, size);
            } else {
                return
                    _wrapWithOrbitalAnimation(content, x, y, centerX, centerY);
            }
        }

        return string.concat("<g>", content, "</g>");
    }

    function _createRings(
        uint16 x,
        uint16 y,
        uint16 size,
        bool pulse,
        bool glitch,
        string memory filterId
    ) internal pure returns (string memory) {
        uint8 sw = _strokeWidth(size);

        string memory glowFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Blur)"')
            : ' filter="url(#blur)"';
        string memory crispFilter = glitch
            ? string.concat(' filter="url(#', filterId, 'Shift)"')
            : "";

        return
            string.concat(
                _ring(x, y, size, sw <= 5 ? sw * 3 : 15, "0.5", glowFilter),
                _ring(x, y, size, sw <= 5 ? sw * 2 : 10, "0.7", glowFilter),
                _ring(x, y, size, sw, "1", crispFilter),
                _highlight(x, y, size, pulse, glitch, filterId)
            );
    }

    function _ring(
        uint16 x,
        uint16 y,
        uint16 size,
        uint8 sw,
        string memory opacity,
        string memory filter
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#ring)" stroke-width="',
                Strings.toString(sw),
                '" opacity="',
                opacity,
                '"',
                filter,
                "/>"
            );
    }

    function _highlight(
        uint16 x,
        uint16 y,
        uint16 size,
        bool pulse,
        bool glitch,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory base = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
            glitch ? string.concat(' filter="url(#', filterId, 'Shift)"') : ""
        );

        return
            pulse
                ? string.concat(
                    base,
                    '><animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                )
                : string.concat(base, "/>");
    }

    function _strokeWidth(uint16 size) internal pure returns (uint8) {
        if (size < 15) return 2;
        uint256 calc = (uint256(size) * 4) / 60;
        return uint8(calc < 2 ? 2 : calc > 15 ? 15 : calc);
    }

    function _wrapWithGrowShrinkAnimation(
        string memory content,
        uint16 size
    ) internal pure returns (string memory) {
        uint16 maxSize = size + 200;

        return
            string.concat(
                "<g>",
                '<animateTransform attributeName="transform" type="scale" ',
                'values="1;',
                _scaleValue(size, maxSize),
                ';1" ',
                'dur="5s" repeatCount="indefinite"/>',
                content,
                "</g>"
            );
    }

    function _wrapWithOrbitalAnimation(
        string memory content,
        uint16 x,
        uint16 y,
        uint16 centerX,
        uint16 centerY
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<g transform="translate(',
                Strings.toString(x),
                ",",
                Strings.toString(y),
                ')">',
                '<animateTransform attributeName="transform" type="rotate" ',
                'values="0 ',
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                ";360 ",
                Strings.toString(centerX),
                " ",
                Strings.toString(centerY),
                '" dur="8s" repeatCount="indefinite"/>',
                content,
                "</g>"
            );
    }

    function _scaleValue(
        uint16 baseSize,
        uint16 maxSize
    ) internal pure returns (string memory) {
        uint256 scaleFactor = (uint256(maxSize) * 100) / uint256(baseSize);
        return
            string.concat(
                Strings.toString(scaleFactor / 100),
                ".",
                Strings.toString(scaleFactor % 100)
            );
    }

    function _animDur(uint256 seed) internal pure returns (string memory) {
        uint256 d = 1 + (seed % 2); // Much faster: 1-2 seconds instead of 3-6
        return string.concat(Strings.toString(d), "s");
    }

    function _createGlitchBlurFilter(
        uint256 seed,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="',
                filterId,
                'Blur" x="-50%" y="-50%" width="200%" height="200%">',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="8" result="blurred"/>',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(15 + (seed % 20)), // Reduced frequency: 15-34 range (was 25-59)
                'e-2" numOctaves="2" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 0.3 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="16" result="bands"/>', // Increased: 16 (was 8)
                '<feDisplacementMap in="blurred" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distBlur">',
                '<animate attributeName="scale" values="0;40;60;0;30;0" dur="',
                dur,
                '" repeatCount="indefinite"/>', // Halved displacement
                "</feDisplacementMap>",
                '<feOffset in="distBlur" dx="6"  dy="0" result="r"/>',
                '<feOffset in="distBlur" dx="-6" dy="0" result="c"/>',
                '<feOffset in="distBlur" dx="0" dy="4" result="g"/>',
                '<feComposite in="r" in2="c" operator="lighter" result="rc"/>',
                '<feComposite in="rc" in2="g" operator="lighter" result="out"/>',
                '<feMerge><feMergeNode in="out"/></feMerge>',
                "</filter>"
            );
    }

    function _createGlitchFilter(
        uint256 seed,
        string memory filterId
    ) internal pure returns (string memory) {
        string memory dur = _animDur(seed);

        return
            string.concat(
                '<filter id="',
                filterId,
                'Shift" x="-50%" y="-50%" width="200%" height="200%">',
                '<feTurbulence type="turbulence" baseFrequency="0.0 ',
                Strings.toString(18 + (seed % 25)), // Reduced frequency: 18-42 range (was 30-69)
                'e-2" numOctaves="3" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0.2 0.8 1 0"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="20" result="bands"/>', // Increased: 20 (was 12)
                '<feDisplacementMap in="SourceGraphic" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distorted">',
                '<animate attributeName="scale" values="0;50;75;10;100;0;25;0" dur="',
                dur,
                '" repeatCount="indefinite"/>', // Halved displacement
                "</feDisplacementMap>",
                '<feOffset in="distorted" dx="8"  dy="0" result="red"/>',
                '<feOffset in="distorted" dx="-8" dy="0" result="cyan"/>',
                '<feOffset in="distorted" dx="0" dy="6" result="yellow"/>',
                '<feComposite in="red" in2="cyan" operator="lighter" result="rc"/>',
                '<feComposite in="rc" in2="yellow" operator="lighter" result="merged"/>',
                '<feMerge><feMergeNode in="merged"/></feMerge>',
                "</filter>"
            );
    }
}
