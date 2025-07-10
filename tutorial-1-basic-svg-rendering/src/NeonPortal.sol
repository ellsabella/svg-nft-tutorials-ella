// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure returns (string memory);
}

contract NeonPortal is INeonPortal {
    function createNeonPortal(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        bool enablePulse
    ) external pure override returns (string memory) {
        // Ensure minimum size to prevent underflow
        if (size < 20) size = 20;

        // Determine if this portal should have glitch effect
        bool enableGlitch = (seed % 5) == 0; // 20% chance

        return
            string.concat(
                _createPortalDefs(seed),
                "<g>",
                _createCloudBase(x, y, size),
                _createNeonRing(x, y, size, enablePulse, enableGlitch),
                "</g>"
            );
    }

    // === DEFINITIONS ===
    function _createPortalDefs(
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                // Multiple offset radial gradients for organic clouds
                '<radialGradient id="portalBg1" cx="0.3" cy="0.2">',
                '<stop offset="0" stop-color="#FF00FF" stop-opacity="0.9"/>',
                '<stop offset="0.6" stop-color="#8000FF" stop-opacity="0.4"/>',
                '<stop offset="1" stop-color="#004080" stop-opacity="0.1"/>',
                "</radialGradient>",
                '<radialGradient id="portalBg2" cx="0.7" cy="0.8">',
                '<stop offset="0" stop-color="#00FFFF" stop-opacity="0.8"/>',
                '<stop offset="0.5" stop-color="#4080FF" stop-opacity="0.3"/>',
                '<stop offset="1" stop-color="#000040" stop-opacity="0.1"/>',
                "</radialGradient>",
                '<radialGradient id="portalBg3" cx="0.1" cy="0.9">',
                '<stop offset="0" stop-color="#FF40FF" stop-opacity="0.7"/>',
                '<stop offset="0.8" stop-color="#200040" stop-opacity="0.2"/>',
                '<stop offset="1" stop-color="#000000" stop-opacity="0.05"/>',
                "</radialGradient>",
                // Ring gradient (cyan to magenta)
                '<linearGradient id="portalRing">',
                '<stop offset="0" stop-color="#00FFFF"/>',
                '<stop offset="1" stop-color="#FF00FF"/>',
                "</linearGradient>",
                // NEW: Horizontal-stripe glitch filter
                _createGlitchFilter(seed),
                "</defs>"
            );
    }

    // === GLITCH FILTER ===
    function _createGlitchFilter(
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="glitchShift" x="-20%" y="-20%" width="140%" height="140%">',
                // 1. horizontal noise (only varies in Y)
                '<feTurbulence type="fractalNoise" baseFrequency="0 0.9" numOctaves="2" seed="',
                Strings.toString(seed % 10000), // cheap uniqueness
                '" result="t"/>',
                // 2. hard-edge bars (values > 0 → 1, else 0)
                '<feColorMatrix in="t" type="matrix" values="1 0 0 0 -0.5  0 1 0 0 -0.5  0 0 1 0 -0.5  0 0 0 1 0" result="bars"/>',
                // 3. keep only the red channel as a 1-bit mask
                '<feComponentTransfer in="bars" result="mask">',
                '<feFuncR type="table" tableValues="0 1"/>',
                "</feComponentTransfer>",
                // 4. shove white bars along X
                '<feDisplacementMap in="SourceGraphic" in2="mask" scale="18" xChannelSelector="R" yChannelSelector="R"/>',
                "</filter>"
            );
    }

    // === CLOUD BASE ===
    function _createCloudBase(
        uint16 x,
        uint16 y,
        uint8 size
    ) internal pure returns (string memory) {
        // Create multiple cloud layers with different sizes and positions
        // Use safe arithmetic to prevent overflow/underflow
        uint16 cloudSize1 = size * 3; // Reduced multiplier
        uint16 cloudSize2 = size * 2; // Reduced multiplier
        uint16 cloudSize3 = size * 3; // Reduced multiplier

        // Safe offset calculations - check bounds before arithmetic
        uint16 pos1X = x > 50 ? x - 50 : 0;
        uint16 pos1Y = y > 80 ? y - 80 : 0;

        // For additions, check if result would exceed uint16 max
        uint16 pos2X = x < 1380 ? x + 60 : 1380; // 1440 - 60 = 1380
        uint16 pos2Y = y < 1400 ? y + 40 : 1400; // 1440 - 40 = 1400

        uint16 pos3X = x > 30 ? x - 30 : 0;
        uint16 pos3Y = y < 1370 ? y + 70 : 1370; // 1440 - 70 = 1370

        return
            string.concat(
                // Layer 1: Main magenta cloud (offset up-left)
                '<circle cx="',
                Strings.toString(pos1X),
                '" cy="',
                Strings.toString(pos1Y),
                '" r="',
                Strings.toString(cloudSize1),
                '" fill="url(#portalBg1)" filter="url(#blur)"/>',
                // Layer 2: Cyan cloud (offset down-right)
                '<circle cx="',
                Strings.toString(pos2X),
                '" cy="',
                Strings.toString(pos2Y),
                '" r="',
                Strings.toString(cloudSize2),
                '" fill="url(#portalBg2)" filter="url(#blur)"/>',
                // Layer 3: Purple accent cloud (offset down-left)
                '<circle cx="',
                Strings.toString(pos3X),
                '" cy="',
                Strings.toString(pos3Y),
                '" r="',
                Strings.toString(cloudSize3),
                '" fill="url(#portalBg3)" filter="url(#blur)"/>'
            );
    }

    // === NEON RING ===
    function _createNeonRing(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse,
        bool enableGlitch
    ) internal pure returns (string memory) {
        uint8 strokeWidth = _getStrokeWidth(size);

        if (enableGlitch) {
            return
                string.concat(
                    // Wide outer glow layer with glitch
                    _createWideGlowLayerGlitch(x, y, size, strokeWidth),
                    // Medium glow layer with glitch
                    _createGlowLayerGlitch(x, y, size, strokeWidth),
                    // Main ring layer with glitch
                    _createMainRingLayerGlitch(x, y, size, strokeWidth),
                    // Inner highlight layer with glitch
                    _createHighlightLayerGlitch(x, y, size, enablePulse)
                );
        } else {
            return
                string.concat(
                    // Standard layers (no glitch)
                    _createWideGlowLayer(x, y, size, strokeWidth),
                    _createGlowLayer(x, y, size, strokeWidth),
                    _createMainRingLayer(x, y, size, strokeWidth),
                    _createHighlightLayer(x, y, size, enablePulse)
                );
        }
    }

    // === WIDE GLOW LAYER GLITCH ===
    function _createWideGlowLayerGlitch(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(wideStrokeWidth),
                '" filter="url(#glitchShift)" opacity="0.5"/>'
            );
    }

    // === GLOW LAYER GLITCH ===
    function _createGlowLayerGlitch(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        uint8 mediumStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            mediumStrokeWidth = strokeWidth * 2;
        } else {
            mediumStrokeWidth = 10;
        }

        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(mediumStrokeWidth),
                '" filter="url(#glitchShift)" opacity="0.7"/>'
            );
    }

    // === MAIN RING LAYER GLITCH ===
    function _createMainRingLayerGlitch(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(strokeWidth),
                '" filter="url(#glitchShift)"/>'
            );
    }

    // === HIGHLIGHT LAYER GLITCH ===
    function _createHighlightLayerGlitch(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        string memory baseHighlight = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9" filter="url(#glitchShift)"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseHighlight,
                    ">",
                    '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                );
        } else {
            return string.concat(baseHighlight, "/>");
        }
    }

    // === WIDE GLOW LAYER ===
    function _createWideGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        // Much thicker stroke for wider glow effect
        uint8 wideStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            wideStrokeWidth = strokeWidth * 3;
        } else {
            wideStrokeWidth = 15;
        }

        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(wideStrokeWidth),
                '" filter="url(#blur)" opacity="0.5"/>'
            );
    }

    // === GLOW LAYER ===
    function _createGlowLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        // Safe multiplication - ensure no overflow
        uint8 glowStrokeWidth = strokeWidth;
        if (strokeWidth <= 5) {
            glowStrokeWidth = strokeWidth * 2; // Reduced multiplier
        } else {
            glowStrokeWidth = 10; // Lower cap
        }

        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(glowStrokeWidth),
                '" filter="url(#blur)" opacity="0.7"/>'
            );
    }

    // === MAIN RING LAYER ===
    function _createMainRingLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint8 strokeWidth
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(x),
                '" cy="',
                Strings.toString(y),
                '" r="',
                Strings.toString(size),
                '" fill="none" stroke="url(#portalRing)" stroke-width="',
                Strings.toString(strokeWidth),
                '"/>'
            );
    }

    // === HIGHLIGHT LAYER ===
    function _createHighlightLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        bool enablePulse
    ) internal pure returns (string memory) {
        string memory baseHighlight = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9"'
        );

        if (enablePulse) {
            return
                string.concat(
                    baseHighlight,
                    ">",
                    '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/>',
                    '<animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/>',
                    "</circle>"
                );
        } else {
            return string.concat(baseHighlight, "/>");
        }
    }

    // === UTILITY FUNCTIONS ===
    function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
        // Follow the same pattern as other shape contracts
        if (size < 15) return 2; // Minimum stroke width

        uint256 calculation = (uint256(size) * 4) / 60;
        if (calculation < 2) return 2;
        if (calculation > 15) return 15; // Cap at 15 for portals
        return uint8(calculation);
    }
}
// pragma solidity ^0.8.26;

// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// interface INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure returns (string memory);
// }

// contract NeonPortal is INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure override returns (string memory) {
//         // Ensure minimum size to prevent underflow
//         if (size < 20) size = 20;

//         return
//             string.concat(
//                 _createPortalDefs(),
//                 "<g>",
//                 // _createCloudBase(x, y, size),
//                 _createNeonRing(x, y, size, enablePulse),
//                 "</g>"
//             );
//     }

//     // === DEFINITIONS ===
//     function _createPortalDefs() internal pure returns (string memory) {
//         return
//             string.concat(
//                 "<defs>",
//                 // Multiple offset radial gradients for organic clouds
//                 '<radialGradient id="portalBg1" cx="0.3" cy="0.2">',
//                 '<stop offset="0" stop-color="#FF00FF" stop-opacity="0.9"/>',
//                 '<stop offset="0.6" stop-color="#8000FF" stop-opacity="0.4"/>',
//                 '<stop offset="1" stop-color="#004080" stop-opacity="0.1"/>',
//                 "</radialGradient>",
//                 '<radialGradient id="portalBg2" cx="0.7" cy="0.8">',
//                 '<stop offset="0" stop-color="#00FFFF" stop-opacity="0.8"/>',
//                 '<stop offset="0.5" stop-color="#4080FF" stop-opacity="0.3"/>',
//                 '<stop offset="1" stop-color="#000040" stop-opacity="0.1"/>',
//                 "</radialGradient>",
//                 '<radialGradient id="portalBg3" cx="0.1" cy="0.9">',
//                 '<stop offset="0" stop-color="#FF40FF" stop-opacity="0.7"/>',
//                 '<stop offset="0.8" stop-color="#200040" stop-opacity="0.2"/>',
//                 '<stop offset="1" stop-color="#000000" stop-opacity="0.05"/>',
//                 "</radialGradient>",
//                 // Ring gradient (cyan to magenta)
//                 '<linearGradient id="portalRing">',
//                 '<stop offset="0" stop-color="#00FFFF"/>',
//                 '<stop offset="1" stop-color="#FF00FF"/>',
//                 "</linearGradient>",
//                 "</defs>"
//             );
//     }

//     // === CLOUD BASE ===
//     function _createCloudBase(
//         uint16 x,
//         uint16 y,
//         uint16 size
//     ) internal pure returns (string memory) {
//         // Create multiple cloud layers with different sizes and positions
//         // Use safe arithmetic to prevent overflow/underflow
//         uint16 cloudSize1 = size * 3; // Reduced multiplier
//         uint16 cloudSize2 = size * 2; // Reduced multiplier
//         uint16 cloudSize3 = size * 3; // Reduced multiplier

//         // Safe offset calculations - check bounds before arithmetic
//         uint16 pos1X = x > 50 ? x - 50 : 0;
//         uint16 pos1Y = y > 80 ? y - 80 : 0;

//         // For additions, check if result would exceed uint16 max
//         uint16 pos2X = x < 1380 ? x + 60 : 1380; // 1440 - 60 = 1380
//         uint16 pos2Y = y < 1400 ? y + 40 : 1400; // 1440 - 40 = 1400

//         uint16 pos3X = x > 30 ? x - 30 : 0;
//         uint16 pos3Y = y < 1370 ? y + 70 : 1370; // 1440 - 70 = 1370

//         return
//             string.concat(
//                 // Layer 1: Main magenta cloud (offset up-left)
//                 '<circle cx="',
//                 Strings.toString(pos1X),
//                 '" cy="',
//                 Strings.toString(pos1Y),
//                 '" r="',
//                 Strings.toString(cloudSize1),
//                 '" fill="url(#portalBg1)" filter="url(#blur)"/>',
//                 // Layer 2: Cyan cloud (offset down-right)
//                 '<circle cx="',
//                 Strings.toString(pos2X),
//                 '" cy="',
//                 Strings.toString(pos2Y),
//                 '" r="',
//                 Strings.toString(cloudSize2),
//                 '" fill="url(#portalBg2)" filter="url(#blur)"/>',
//                 // Layer 3: Purple accent cloud (offset down-left)
//                 '<circle cx="',
//                 Strings.toString(pos3X),
//                 '" cy="',
//                 Strings.toString(pos3Y),
//                 '" r="',
//                 Strings.toString(cloudSize3),
//                 '" fill="url(#portalBg3)" filter="url(#blur)"/>'
//             );
//     }

//     // === NEON RING ===
//     function _createNeonRing(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         bool enablePulse
//     ) internal pure returns (string memory) {
//         uint8 strokeWidth = _getStrokeWidth(size);

//         return
//             string.concat(
//                 // Wide outer glow layer (like red circles)
//                 _createWideGlowLayer(x, y, size, strokeWidth),
//                 // Medium glow layer
//                 _createGlowLayer(x, y, size, strokeWidth),
//                 // Main ring layer
//                 _createMainRingLayer(x, y, size, strokeWidth),
//                 // Inner highlight layer
//                 _createHighlightLayer(x, y, size, enablePulse)
//             );
//     }

//     // === WIDE GLOW LAYER (NEW) ===
//     function _createWideGlowLayer(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         // Much thicker stroke for wider glow effect
//         uint8 wideStrokeWidth = strokeWidth * 3;
//         if (wideStrokeWidth > 20) wideStrokeWidth = 20;

//         return
//             string.concat(
//                 '<circle cx="',
//                 Strings.toString(x),
//                 '" cy="',
//                 Strings.toString(y),
//                 '" r="',
//                 Strings.toString(size),
//                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
//                 Strings.toString(wideStrokeWidth),
//                 '" filter="url(#blur)" opacity="0.4"/>'
//             );
//     }

//     // === GLOW LAYER ===
//     function _createGlowLayer(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         // Safe multiplication - ensure no overflow
//         uint8 glowStrokeWidth = strokeWidth;
//         if (strokeWidth <= 5) {
//             glowStrokeWidth = strokeWidth * 2; // Reduced multiplier
//         } else {
//             glowStrokeWidth = 10; // Lower cap
//         }

//         return
//             string.concat(
//                 '<circle cx="',
//                 Strings.toString(x),
//                 '" cy="',
//                 Strings.toString(y),
//                 '" r="',
//                 Strings.toString(size),
//                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
//                 Strings.toString(glowStrokeWidth),
//                 '" filter="url(#blur)" opacity="0.6"/>'
//             );
//     }

//     // === MAIN RING LAYER ===
//     function _createMainRingLayer(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         return
//             string.concat(
//                 '<circle cx="',
//                 Strings.toString(x),
//                 '" cy="',
//                 Strings.toString(y),
//                 '" r="',
//                 Strings.toString(size),
//                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
//                 Strings.toString(strokeWidth),
//                 '"/>'
//             );
//     }

//     // === HIGHLIGHT LAYER ===
//     function _createHighlightLayer(
//         uint16 x,
//         uint16 y,
//         uint16 size,
//         bool enablePulse
//     ) internal pure returns (string memory) {
//         string memory baseHighlight = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="white" stroke-width="2" opacity="0.9"'
//         );

//         if (enablePulse) {
//             return
//                 string.concat(
//                     baseHighlight,
//                     ">",
//                     '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/>',
//                     '<animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/>',
//                     "</circle>"
//                 );
//         } else {
//             return string.concat(baseHighlight, "/>");
//         }
//     }

//     // === UTILITY FUNCTIONS ===
//     function _getStrokeWidth(uint16 size) internal pure returns (uint8) {
//         // Follow the same pattern as other shape contracts
//         if (size < 15) return 2; // Minimum stroke width

//         uint256 calculation = (uint256(size) * 4) / 60;
//         if (calculation < 2) return 2;
//         if (calculation > 15) return 15; // Cap at 15 for portals
//         return uint8(calculation);
//     }
// }
