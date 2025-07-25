// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {CircleTypes} from "./CircleTypes.sol";

interface ICircularShapes {
    function createCircle(
        CircleTypes.Config memory config,
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);
}

contract CircularShapes is ICircularShapes {
    function createCircle(
        CircleTypes.Config memory config,
        string memory colorA,
        string memory colorB
    ) external pure override returns (string memory) {
        if (config.size < 10) config.size = 10;

        string memory gradientDefs = config.useGradient
            ? _createGradientDefs(colorA, colorB, config.seed)
            : "";
        string memory glitchDefs = config.enableGlitch
            ? _createGlitchDefs(config.seed)
            : "";

        return
            string.concat(
                gradientDefs,
                glitchDefs,
                "<g>",
                _createWideGlowLayer(config, colorA, colorB),
                _createMediumGlowLayer(config, colorA, colorB),
                _createCrispLayer(config, colorA, colorB),
                _createWhiteHotLayer(config),
                "</g>"
            );
    }

    function _createGradientDefs(
        string memory colorA,
        string memory colorB,
        uint256 seed
    ) internal pure returns (string memory) {
        string memory gradientId = string.concat(
            "grad",
            Strings.toString(seed % 10000)
        );

        return
            string.concat(
                "<defs>",
                '<linearGradient id="',
                gradientId,
                '">',
                '<stop offset="0" stop-color="',
                colorA,
                '"/>',
                '<stop offset="0.7" stop-color="',
                colorB,
                '"/>',
                '<stop offset="1" stop-color="',
                colorA,
                '"/>',
                "</linearGradient>",
                "</defs>"
            );
    }

    function _createGlitchDefs(
        uint256 seed
    ) internal pure returns (string memory) {
        string memory filterId = string.concat(
            "glitch",
            Strings.toString(seed % 10000)
        );

        return
            string.concat(
                "<defs>",
                _createGlitchFilter(seed, filterId),
                _createGlitchBlurFilter(seed, filterId),
                "</defs>"
            );
    }

    function _createWideGlowLayer(
        CircleTypes.Config memory config,
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(config.size, config.useGradient);
        uint8 wideStrokeWidth = strokeWidth <= 5 ? strokeWidth * 3 : 15;

        string memory stroke = config.useGradient
            ? string.concat(
                "url(#grad",
                Strings.toString(config.seed % 10000),
                ")"
            )
            : colorA;

        string memory filter = config.enableGlitch
            ? string.concat(
                ' filter="url(#glitch',
                Strings.toString(config.seed % 10000),
                'Blur)"'
            )
            : ' filter="url(#blur)"';

        return
            string.concat(
                '<circle cx="',
                Strings.toString(config.x),
                '" cy="',
                Strings.toString(config.y),
                '" r="',
                Strings.toString(config.size),
                '" fill="none" stroke="',
                stroke,
                '" stroke-width="',
                Strings.toString(wideStrokeWidth),
                '" opacity="0.5"',
                filter,
                "/>"
            );
    }

    function _createMediumGlowLayer(
        CircleTypes.Config memory config,
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(config.size, config.useGradient);
        uint8 mediumStrokeWidth = strokeWidth <= 5 ? strokeWidth * 2 : 10;

        string memory stroke = config.useGradient
            ? string.concat(
                "url(#grad",
                Strings.toString(config.seed % 10000),
                ")"
            )
            : colorA;

        string memory filter = config.enableGlitch
            ? string.concat(
                ' filter="url(#glitch',
                Strings.toString(config.seed % 10000),
                'Blur)"'
            )
            : ' filter="url(#blur)"';

        return
            string.concat(
                '<circle cx="',
                Strings.toString(config.x),
                '" cy="',
                Strings.toString(config.y),
                '" r="',
                Strings.toString(config.size),
                '" fill="none" stroke="',
                stroke,
                '" stroke-width="',
                Strings.toString(mediumStrokeWidth),
                '" opacity="0.7"',
                filter,
                "/>"
            );
    }

    function _createCrispLayer(
        CircleTypes.Config memory config,
        string memory colorA,
        string memory colorB
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(config.size, config.useGradient);

        string memory stroke = config.useGradient
            ? string.concat(
                "url(#grad",
                Strings.toString(config.seed % 10000),
                ")"
            )
            : colorA;

        string memory filter = config.enableGlitch
            ? string.concat(
                ' filter="url(#glitch',
                Strings.toString(config.seed % 10000),
                'Shift)"'
            )
            : "";

        return
            string.concat(
                '<circle cx="',
                Strings.toString(config.x),
                '" cy="',
                Strings.toString(config.y),
                '" r="',
                Strings.toString(config.size),
                '" fill="none" stroke="',
                stroke,
                '" stroke-width="',
                Strings.toString(strokeWidth),
                '"',
                filter,
                "/>"
            );
    }

    function _createWhiteHotLayer(
        CircleTypes.Config memory config
    ) internal pure returns (string memory) {
        string memory filter = config.enableGlitch
            ? string.concat(
                ' filter="url(#glitch',
                Strings.toString(config.seed % 10000),
                'Shift)"'
            )
            : "";

        return
            string.concat(
                '<circle cx="',
                Strings.toString(config.x),
                '" cy="',
                Strings.toString(config.y),
                '" r="',
                Strings.toString(config.size),
                '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
                filter,
                "/>"
            );
    }

    function _getStrokeWidth(
        uint16 size,
        bool useGradient
    ) internal pure returns (uint8) {
        if (size < 15) return 2;
        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;

        // Different max values: red circles = 10, neon portals = 15
        uint8 maxWidth = useGradient ? 15 : 10;
        if (calculation > maxWidth) return maxWidth;
        return uint8(calculation);
    }

    // Glitch filter functions (with animations restored)
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
                Strings.toString(15 + (seed % 20)),
                'e-2" numOctaves="2" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0 0.3 1 1"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="16" result="bands"/>',
                '<feDisplacementMap in="blurred" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distBlur">',
                '<animate attributeName="scale" values="0;40;60;0;30;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                '<feOffset in="distBlur" dx="6" dy="0" result="r"/>',
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
                Strings.toString(18 + (seed % 25)),
                'e-2" numOctaves="3" seed="',
                Strings.toString(seed % 10000),
                '" result="raw"/>',
                '<feComponentTransfer in="raw" result="mask">',
                '<feFuncR type="table" tableValues="0 0.2 0.8 1 0"/>',
                "</feComponentTransfer>",
                '<feMorphology in="mask" operator="dilate" radius="20" result="bands"/>',
                '<feDisplacementMap in="SourceGraphic" in2="bands" scale="0" ',
                'xChannelSelector="R" yChannelSelector="R" result="distorted">',
                '<animate attributeName="scale" values="0;50;75;10;100;0;25;0" dur="',
                dur,
                '" repeatCount="indefinite"/>',
                "</feDisplacementMap>",
                '<feOffset in="distorted" dx="8" dy="0" result="red"/>',
                '<feOffset in="distorted" dx="-8" dy="0" result="cyan"/>',
                '<feOffset in="distorted" dx="0" dy="6" result="yellow"/>',
                '<feComposite in="red" in2="cyan" operator="lighter" result="rc"/>',
                '<feComposite in="rc" in2="yellow" operator="lighter" result="merged"/>',
                '<feMerge><feMergeNode in="merged"/></feMerge>',
                "</filter>"
            );
    }

    function _animDur(uint256 seed) internal pure returns (string memory) {
        uint256 d = 1 + (seed % 2); // 1-2 seconds for fast glitch
        return string.concat(Strings.toString(d), "s");
    }
}
