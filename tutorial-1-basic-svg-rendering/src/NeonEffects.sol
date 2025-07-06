// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface INeonEffects {
    enum GlowIntensity {
        LOW,
        MEDIUM,
        HIGH,
        EXTREME,
        PULSE_SLOW,
        PULSE_FAST,
        PULSE_EXTREME
    }

    function createEnhancedFilters() external pure returns (string memory);

    function getFilterReference(
        GlowIntensity intensity
    ) external pure returns (string memory);

    function isPulsing(GlowIntensity intensity) external pure returns (bool);

    function createPulseOpacityAnimation(
        GlowIntensity intensity
    ) external pure returns (string memory);

    function createWhiteHotStroke(
        uint256 shapeType,
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 seed
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
                // Restore original powerful blur filter as the baseline for bars
                _createOriginalBlurFilter(),
                // Shape-specific filters - START HIGHER than the bar filter for more impact
                _createStaticGlowFilter("glow-shape-low", 20, 50, 6, "0.9"), // Shapes start higher than bars
                _createStaticGlowFilter("glow-med", 30, 70, 8, "1.1"), // Medium boost
                _createStaticGlowFilter("glow-high", 40, 90, 10, "1.2"), // High intensity
                _createStaticGlowFilter("glow-extreme", 60, 140, 12, "1.4"), // Extreme "on fire"
                // Animated pulsing filters for shapes
                _createPulsingGlowFilter("glow-pulse-slow", 3), // 3 second pulse
                _createPulsingGlowFilter("glow-pulse-fast", 1), // 1 second pulse
                _createPulsingGlowFilter("glow-pulse-extreme", 2), // 2 second extreme pulse
                // Existing specular filter
                _createSpecularFilter(),
                "</defs>"
            );
    }

    function _createOriginalBlurFilter() internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="blur" filterUnits="userSpaceOnUse" ',
                'x="-720" y="-720" width="2160" height="2160">',
                // Initial blur to create the glow base
                '<feGaussianBlur in="SourceGraphic" stdDeviation="15" result="innerGlow"/>',
                // Brighten and colorize the glow
                '<feColorMatrix in="innerGlow" type="matrix" values="',
                "4 0 0 0 0.1 ", // More intense red
                "0 4 0 0 0.1 ", // More intense green
                "0 0 4 0 0.1 ", // More intense blue
                '0 0 0 0.8 0" result="brightGlow"/>',
                // Create wider outer halo
                '<feGaussianBlur in="brightGlow" stdDeviation="40" result="outerHalo"/>',
                // Layer the effects: wide halo + bright glow + original
                "<feMerge>",
                '<feMergeNode in="outerHalo"/>',
                '<feMergeNode in="brightGlow"/>',
                '<feMergeNode in="SourceGraphic"/>',
                "</feMerge>",
                "</filter>"
            );
    }

    function _createStaticGlowFilter(
        string memory id,
        uint256 innerBlur,
        uint256 outerBlur,
        uint256 colorMultiplier,
        string memory opacity
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="',
                id,
                '" filterUnits="userSpaceOnUse" x="-720" y="-720" width="2160" height="2160">',
                // Layer 1: Tight, intense colored glow - REDUCE multiplier to keep color
                '<feGaussianBlur in="SourceGraphic" stdDeviation="8" result="tightGlow"/>',
                '<feColorMatrix in="tightGlow" type="matrix" values="',
                Strings.toString(colorMultiplier),
                " 0 0 0 0.1 ", // Reduced from 2x multiplier
                "0 ",
                Strings.toString(colorMultiplier),
                " 0 0 0.1 ", // Lower offset for view color
                "0 0 ",
                Strings.toString(colorMultiplier),
                " 0 0.1 ",
                '0 0 0 1.2 0" result="intenseTightGlow"/>', // Reduced opacity
                // Layer 2: Medium colored glow - KEEP color saturation
                '<feGaussianBlur in="SourceGraphic" stdDeviation="',
                Strings.toString(innerBlur),
                '" result="innerGlow"/>',
                '<feColorMatrix in="innerGlow" type="matrix" values="',
                Strings.toString(colorMultiplier / 2),
                " 0 0 0 0.05 ", // HALF the multiplier for more color
                "0 ",
                Strings.toString(colorMultiplier / 2),
                " 0 0 0.05 ",
                "0 0 ",
                Strings.toString(colorMultiplier / 2),
                " 0 0.05 ",
                "0 0 0 ",
                opacity,
                ' 0" result="brightGlow"/>',
                // Layer 3: Wide outer halo - MORE colorful, less white
                '<feGaussianBlur in="brightGlow" stdDeviation="',
                Strings.toString(outerBlur),
                '" result="outerHalo"/>',
                '<feColorMatrix in="outerHalo" type="matrix" values="',
                '0.8 0 0 0 0 0 0.8 0 0 0 0 0 0.8 0 0 0 0 0 0.4 0" result="dimHalo"/>', // Increased from 0.5 to 0.8
                // Merge all layers: wide dim halo + medium glow + tight intense glow + original sharp shape
                "<feMerge>",
                '<feMergeNode in="dimHalo"/>',
                '<feMergeNode in="brightGlow"/>',
                '<feMergeNode in="intenseTightGlow"/>',
                '<feMergeNode in="SourceGraphic"/>',
                "</feMerge>",
                "</filter>"
            );
    }

    function _createPulsingGlowFilter(
        string memory id,
        uint256 duration
    ) internal pure returns (string memory) {
        string memory dur = Strings.toString(duration);

        return
            string.concat(
                '<filter id="',
                id,
                '" filterUnits="userSpaceOnUse" x="-720" y="-720" width="2160" height="2160">',
                // Layer 1: Animated tight glow - REDUCE multipliers for more color
                '<feGaussianBlur in="SourceGraphic" result="tightGlow">',
                '<animate attributeName="stdDeviation" values="6;15;6" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feGaussianBlur>",
                '<feColorMatrix in="tightGlow" type="matrix" result="intenseTightGlow">',
                '<animate attributeName="values" values="',
                "12 0 0 0 0.1 0 12 0 0 0.1 0 0 12 0 0.1 0 0 0 1.2 0;", // Reduced from 20x to 12x
                "25 0 0 0 0.3 0 25 0 0 0.3 0 0 25 0 0.3 0 0 0 1.6 0;", // Reduced from 60x to 25x
                '12 0 0 0 0.1 0 12 0 0 0.1 0 0 12 0 0.1 0 0 0 1.2 0"', // Back to 12x
                ' dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feColorMatrix>",
                // Layer 2: Animated medium glow - REDUCE multipliers
                '<feGaussianBlur in="SourceGraphic" result="innerGlow">',
                '<animate attributeName="stdDeviation" values="25;50;25" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feGaussianBlur>",
                '<feColorMatrix in="innerGlow" type="matrix" result="brightGlow">',
                '<animate attributeName="values" values="',
                "6 0 0 0 0.05 0 6 0 0 0.05 0 0 6 0 0.05 0 0 0 1.0 0;", // Reduced from 15x to 6x
                "12 0 0 0 0.15 0 12 0 0 0.15 0 0 12 0 0.15 0 0 0 1.4 0;", // Reduced from 30x to 12x
                '6 0 0 0 0.05 0 6 0 0 0.05 0 0 6 0 0.05 0 0 0 1.0 0"', // Back to 6x
                ' dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feColorMatrix>",
                // Layer 3: Animated outer halo - MORE colorful
                '<feGaussianBlur in="brightGlow" result="outerHalo">',
                '<animate attributeName="stdDeviation" values="60;120;60" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feGaussianBlur>",
                '<feColorMatrix in="outerHalo" type="matrix" values="',
                '0.7 0 0 0 0 0 0.7 0 0 0 0 0 0.7 0 0 0 0 0 0.35 0" result="dimHalo"/>', // More colorful
                // NEW: "White hot" effect for the original shape - MUCH more dramatic
                '<feColorMatrix in="SourceGraphic" type="matrix" result="heatedShape">',
                '<animate attributeName="values" values="',
                "1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0;", // Normal colors
                "1 0 0 0 1.5 0 1 0 0 1.5 0 0 1 0 1.5 0 0 0 1 0;", // NUCLEAR white (1.5 = guaranteed view white)
                '1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 1 0"', // Back to normal
                ' dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</feColorMatrix>",
                // Merge: dim halo + medium glow + heated shape + tight glow (tight glow on top for definition)
                "<feMerge>",
                '<feMergeNode in="dimHalo"/>',
                '<feMergeNode in="brightGlow"/>',
                '<feMergeNode in="heatedShape"/>', // Move heated shape BEFORE tight glow
                '<feMergeNode in="intenseTightGlow"/>', // Tight glow on top for edge definition
                "</feMerge>",
                "</filter>"
            );
    }

    function _createSpecularFilter() internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="spec" filterUnits="userSpaceOnUse" x="-720" y="-720" width="2160" height="2160">',
                '<feSpecularLighting result="specOut" lighting-color="white" specularConstant="2" specularExponent="20">',
                '<fePointLight x="360" y="360" z="200"/>',
                "</feSpecularLighting>",
                '<feComposite in="specOut" in2="SourceAlpha" operator="in"/>',
                '<feComposite in="SourceGraphic" in2="specOut" operator="arithmetic" k1="0" k2="1" k3="1" k4="0"/>',
                "</filter>"
            );
    }

    function getFilterReference(
        GlowIntensity intensity
    ) external pure override returns (string memory) {
        if (intensity == GlowIntensity.LOW) return "glow-shape-low"; // Shapes start with higher glow than bars
        if (intensity == GlowIntensity.MEDIUM) return "glow-med";
        if (intensity == GlowIntensity.HIGH) return "glow-high";
        if (intensity == GlowIntensity.EXTREME) return "glow-extreme";
        if (intensity == GlowIntensity.PULSE_SLOW) return "glow-pulse-slow";
        if (intensity == GlowIntensity.PULSE_FAST) return "glow-pulse-fast";
        if (intensity == GlowIntensity.PULSE_EXTREME)
            return "glow-pulse-extreme";
        return "glow-shape-low"; // fallback to shape-specific higher glow
    }

    function isPulsing(
        GlowIntensity intensity
    ) external pure override returns (bool) {
        return
            intensity == GlowIntensity.PULSE_SLOW ||
            intensity == GlowIntensity.PULSE_FAST ||
            intensity == GlowIntensity.PULSE_EXTREME;
    }

    function createPulseOpacityAnimation(
        GlowIntensity intensity
    ) external pure override returns (string memory) {
        string memory duration = "2"; // default
        if (intensity == GlowIntensity.PULSE_FAST) duration = "1";
        if (intensity == GlowIntensity.PULSE_SLOW) duration = "3";

        return
            string.concat(
                '<animate attributeName="opacity" values="0.7;1.0;0.7" dur="',
                duration,
                's" repeatCount="indefinite"/>'
            );
    }

    function createWhiteHotStroke(
        uint256 shapeType,
        uint256 x,
        uint256 y,
        GlowIntensity intensity,
        uint256 seed
    ) external pure override returns (string memory) {
        string memory dur = intensity == GlowIntensity.PULSE_FAST
            ? "1"
            : intensity == GlowIntensity.PULSE_SLOW
            ? "3"
            : "2";

        if (shapeType == 0) {
            // Circle - unchanged
            return
                string.concat(
                    "<g>",
                    '<circle cx="',
                    Strings.toString(x),
                    '" cy="',
                    Strings.toString(y),
                    '" r="60" fill="none" stroke="white" stroke-width="3" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</circle>",
                    "</g>"
                );
        } else if (shapeType == 1) {
            // Diamond - with rotation
            return
                string.concat(
                    "<g>",
                    '<g transform="translate(',
                    Strings.toString(x),
                    ",",
                    Strings.toString(y),
                    ") rotate(",
                    _intToString(int256((seed % 61)) - 30),
                    ')">',
                    '<polygon points="0,-25 50,0 0,25 -50,0" fill="none" stroke="white" stroke-width="3" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</polygon>",
                    "</g>",
                    "</g>"
                );
        } else {
            // Square - unchanged
            return
                string.concat(
                    "<g>",
                    '<rect x="',
                    Strings.toString(x - 25),
                    '" y="',
                    Strings.toString(y - 25),
                    '" width="50" height="50" fill="none" stroke="white" stroke-width="3" filter="url(#blur)" stroke-opacity="0.4">',
                    '<animate attributeName="opacity" values="0;0.6;0" dur="',
                    dur,
                    's" repeatCount="indefinite"/>',
                    "</rect>",
                    "</g>"
                );
        }
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
