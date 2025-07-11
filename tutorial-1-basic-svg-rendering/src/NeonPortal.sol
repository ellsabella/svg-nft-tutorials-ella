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
        if (size < 20) size = 20;

        return
            string.concat(
                _createDefs(seed),
                "<g>",
                _createBokeh(x, y, size, seed),
                _createRings(x, y, size, enablePulse, (seed % 5) == 0),
                "</g>"
            );
    }

    function _createDefs(uint256 seed) internal pure returns (string memory) {
        return
            string.concat(
                "<defs>",
                '<linearGradient id="ring"><stop offset="0" stop-color="#00FFFF"/><stop offset="1" stop-color="#FF00FF"/></linearGradient>',
                '<filter id="glitch" x="-20%" y="-20%" width="140%" height="140%"><feTurbulence type="fractalNoise" baseFrequency="0 0.9" numOctaves="2" seed="',
                Strings.toString(seed % 10000),
                '" result="t"/><feColorMatrix in="t" type="matrix" values="1 0 0 0 -0.5 0 1 0 0 -0.5 0 0 1 0 -0.5 0 0 0 1 0" result="bars"/><feComponentTransfer in="bars" result="mask"><feFuncR type="table" tableValues="0 1"/></feComponentTransfer><feDisplacementMap in="SourceGraphic" in2="mask" scale="18" xChannelSelector="R" yChannelSelector="R"/></filter>',
                "</defs>"
            );
    }

    function _createBokeh(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                _bokehLayer(x, y, size, seed, 4, 7, 20, 40, "b1"),
                _bokehLayer(x, y, size, seed + 1111, 3, 9, 12, 25, "b2"),
                _bokehLayer(x, y, size, seed + 2222, 2, 11, 6, 15, "b3")
            );
    }

    // function _createBokeh(
    //     uint16 x,
    //     uint16 y,
    //     uint8 size,
    //     uint256 seed
    // ) internal pure returns (string memory) {
    //     return
    //         string.concat(
    //             _bokehLayer(x, y, size, seed, 4, 7, 20, 40, "#88FFFF"), // bright cyan
    //             _bokehLayer(x, y, size, seed + 1111, 3, 9, 12, 25, "#FF88FF"), // bright magenta
    //             _bokehLayer(x, y, size, seed + 2222, 2, 11, 6, 15, "#CCAAFF") // bright purple
    //         );
    // }

    function _bokehLayer(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 seed,
        uint8 spread,
        uint8 count,
        uint8 minSize,
        uint8 sizeRange,
        string memory grad
    ) internal pure returns (string memory) {
        string memory result = "";

        for (uint8 i = 0; i < count; i++) {
            result = string.concat(
                result,
                _bokehCircle(
                    x,
                    y,
                    size,
                    seed + uint256(i) * 1000,
                    spread,
                    minSize,
                    sizeRange,
                    grad
                )
            );
        }
        return result;
    }

    function _bokehCircle(
        uint16 x,
        uint16 y,
        uint8 size,
        uint256 s,
        uint8 spread,
        uint8 minSize,
        uint8 sizeRange,
        string memory grad
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<circle cx="',
                Strings.toString(_calcPos(x, s % 360, size, spread)),
                '" cy="',
                Strings.toString(_calcPos(y, (s >> 16) % 360, size, spread)),
                '" r="',
                Strings.toString(minSize + uint8(s % sizeRange)),
                '" fill="url(#',
                grad,
                ')" filter="url(#blur)"/>'
            );
    }

    function _calcPos(
        uint16 center,
        uint256 rand,
        uint8 size,
        uint8 spread
    ) internal pure returns (uint16) {
        // Use full 360 range for circular distribution
        uint256 angle = rand; // 0-359
        uint256 distance = ((angle % 100) * uint256(size) * uint256(spread)) /
            100; // vary distance

        // Convert to offset using simplified trig (avoiding actual sin/cos)
        uint256 offsetX = distance * ((angle % 4) > 1 ? 1 : 0); // rough X component
        uint256 offsetY = distance * ((angle % 4) > 2 ? 1 : 0); // rough Y component

        // Apply direction
        bool xPos = (angle % 2) == 0;
        bool yPos = (angle % 8) < 4;

        uint16 resultX = xPos
            ? center + uint16(offsetX)
            : (center > offsetX ? center - uint16(offsetX) : 0);
        return
            yPos
                ? resultX
                : (resultX > offsetY ? resultX - uint16(offsetY) : 0);
    }

    function _createRings(
        uint16 x,
        uint16 y,
        uint8 size,
        bool pulse,
        bool glitch
    ) internal pure returns (string memory) {
        uint8 sw = _strokeWidth(size);

        if (glitch) {
            return
                string.concat(
                    _ring(
                        x,
                        y,
                        size,
                        sw <= 5 ? sw * 3 : 15,
                        "0.5",
                        ' filter="url(#glitch)"'
                    ),
                    _ring(
                        x,
                        y,
                        size,
                        sw <= 5 ? sw * 2 : 10,
                        "0.7",
                        ' filter="url(#glitch)"'
                    ),
                    _ring(x, y, size, sw, "1", ' filter="url(#glitch)"'),
                    _highlight(x, y, size, pulse, true)
                );
        } else {
            return
                string.concat(
                    _ring(
                        x,
                        y,
                        size,
                        sw <= 5 ? sw * 3 : 15,
                        "0.5",
                        ' filter="url(#blur)"'
                    ),
                    _ring(
                        x,
                        y,
                        size,
                        sw <= 5 ? sw * 2 : 10,
                        "0.7",
                        ' filter="url(#blur)"'
                    ),
                    _ring(x, y, size, sw, "1", ""),
                    _highlight(x, y, size, pulse, false)
                );
        }
    }

    function _ring(
        uint16 x,
        uint16 y,
        uint8 size,
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
        uint8 size,
        bool pulse,
        bool glitch
    ) internal pure returns (string memory) {
        string memory base = string.concat(
            '<circle cx="',
            Strings.toString(x),
            '" cy="',
            Strings.toString(y),
            '" r="',
            Strings.toString(size),
            '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
            glitch ? ' filter="url(#glitch)"' : ""
        );

        return
            pulse
                ? string.concat(
                    base,
                    '><animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/><animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/></circle>'
                )
                : string.concat(base, "/>");
    }

    function _strokeWidth(uint8 size) internal pure returns (uint8) {
        if (size < 15) return 2;
        uint256 calc = (uint256(size) * 4) / 60;
        return uint8(calc < 2 ? 2 : calc > 15 ? 15 : calc);
    }
}
// pragma solidity ^0.8.26;

// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// interface INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure returns (string memory);
// }

// contract NeonPortal is INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure override returns (string memory) {
//         if (size < 20) size = 20;

//         return
//             string.concat(
//                 _createDefs(seed),
//                 "<g>",
//                 _createBokeh(x, y, size, seed),
//                 _createRings(x, y, size, enablePulse, (seed % 5) == 0),
//                 "</g>"
//             );
//     }

//     function _createDefs(uint256 seed) internal pure returns (string memory) {
//         return
//             string.concat(
//                 "<defs>",
//                 '<radialGradient id="b1"><stop offset="0" stop-color="#FFF" stop-opacity="0.8"/><stop offset="0.3" stop-color="#E0E0FF" stop-opacity="0.4"/><stop offset="1" stop-color="#C0C0E0" stop-opacity="0.1"/></radialGradient>',
//                 '<radialGradient id="b2"><stop offset="0" stop-color="#FFE0FF" stop-opacity="0.7"/><stop offset="0.4" stop-color="#E0C0E0" stop-opacity="0.3"/><stop offset="1" stop-color="#C0A0C0" stop-opacity="0.05"/></radialGradient>',
//                 '<radialGradient id="b3"><stop offset="0" stop-color="#E0FFFF" stop-opacity="0.6"/><stop offset="0.5" stop-color="#C0E0E0" stop-opacity="0.2"/><stop offset="1" stop-color="#A0C0C0" stop-opacity="0.03"/></radialGradient>',
//                 '<linearGradient id="ring"><stop offset="0" stop-color="#00FFFF"/><stop offset="1" stop-color="#FF00FF"/></linearGradient>',
//                 '<filter id="glitch" x="-20%" y="-20%" width="140%" height="140%"><feTurbulence type="fractalNoise" baseFrequency="0 0.9" numOctaves="2" seed="',
//                 Strings.toString(seed % 10000),
//                 '" result="t"/><feColorMatrix in="t" type="matrix" values="1 0 0 0 -0.5 0 1 0 0 -0.5 0 0 1 0 -0.5 0 0 0 1 0" result="bars"/><feComponentTransfer in="bars" result="mask"><feFuncR type="table" tableValues="0 1"/></feComponentTransfer><feDisplacementMap in="SourceGraphic" in2="mask" scale="18" xChannelSelector="R" yChannelSelector="R"/></filter>',
//                 "</defs>"
//             );
//     }

//     function _createBokeh(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed
//     ) internal pure returns (string memory) {
//         return
//             string.concat(
//                 _bokehLayer(x, y, size, seed, 4, 7, 20, 40, "b1"),
//                 _bokehLayer(x, y, size, seed + 1111, 3, 9, 12, 25, "b2"),
//                 _bokehLayer(x, y, size, seed + 2222, 2, 11, 6, 15, "b3")
//             );
//     }

//     // function _createBokeh(
//     //     uint16 x,
//     //     uint16 y,
//     //     uint8 size,
//     //     uint256 seed
//     // ) internal pure returns (string memory) {
//     //     return
//     //         string.concat(
//     //             _bokehLayer(x, y, size, seed, 4, 7, 20, 40, "b1"),
//     //             _bokehLayer(x, y, size, seed + 1111, 3, 9, 12, 25, "b2"),
//     //             _bokehLayer(x, y, size, seed + 2222, 2, 11, 6, 15, "b3")
//     //         );
//     // }

//     function _bokehLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         uint8 spread,
//         uint8 count,
//         uint8 minSize,
//         uint8 sizeRange,
//         string memory grad
//     ) internal pure returns (string memory) {
//         string memory result = "";

//         for (uint8 i = 0; i < count; i++) {
//             result = string.concat(
//                 result,
//                 _bokehCircle(
//                     x,
//                     y,
//                     size,
//                     seed + uint256(i) * 1000,
//                     spread,
//                     minSize,
//                     sizeRange,
//                     grad
//                 )
//             );
//         }
//         return result;
//     }

//     function _bokehCircle(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 s,
//         uint8 spread,
//         uint8 minSize,
//         uint8 sizeRange,
//         string memory grad
//     ) internal pure returns (string memory) {
//         return
//             string.concat(
//                 '<circle cx="',
//                 Strings.toString(_calcPos(x, s % 200, size, spread)),
//                 '" cy="',
//                 Strings.toString(_calcPos(y, (s >> 8) % 200, size, spread)),
//                 '" r="',
//                 Strings.toString(minSize + uint8(s % sizeRange)),
//                 '" fill="url(#',
//                 grad,
//                 ')" filter="url(#blur)"/>'
//             );
//     }

//     function _calcPos(
//         uint16 center,
//         uint256 rand,
//         uint8 size,
//         uint8 spread
//     ) internal pure returns (uint16) {
//         uint256 offset = ((rand > 100 ? rand - 100 : 100 - rand) *
//             uint256(size) *
//             uint256(spread)) / 100;
//         return
//             rand > 100
//                 ? center + uint16(offset)
//                 : (center > offset ? center - uint16(offset) : 0);
//     }

//     function _createRings(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         bool pulse,
//         bool glitch
//     ) internal pure returns (string memory) {
//         uint8 sw = _strokeWidth(size);

//         if (glitch) {
//             return
//                 string.concat(
//                     _ring(
//                         x,
//                         y,
//                         size,
//                         sw <= 5 ? sw * 3 : 15,
//                         "0.5",
//                         ' filter="url(#glitch)"'
//                     ),
//                     _ring(
//                         x,
//                         y,
//                         size,
//                         sw <= 5 ? sw * 2 : 10,
//                         "0.7",
//                         ' filter="url(#glitch)"'
//                     ),
//                     _ring(x, y, size, sw, "1", ' filter="url(#glitch)"'),
//                     _highlight(x, y, size, pulse, true)
//                 );
//         } else {
//             return
//                 string.concat(
//                     _ring(
//                         x,
//                         y,
//                         size,
//                         sw <= 5 ? sw * 3 : 15,
//                         "0.5",
//                         ' filter="url(#blur)"'
//                     ),
//                     _ring(
//                         x,
//                         y,
//                         size,
//                         sw <= 5 ? sw * 2 : 10,
//                         "0.7",
//                         ' filter="url(#blur)"'
//                     ),
//                     _ring(x, y, size, sw, "1", ""),
//                     _highlight(x, y, size, pulse, false)
//                 );
//         }
//     }

//     function _ring(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 sw,
//         string memory opacity,
//         string memory filter
//     ) internal pure returns (string memory) {
//         return
//             string.concat(
//                 '<circle cx="',
//                 Strings.toString(x),
//                 '" cy="',
//                 Strings.toString(y),
//                 '" r="',
//                 Strings.toString(size),
//                 '" fill="none" stroke="url(#ring)" stroke-width="',
//                 Strings.toString(sw),
//                 '" opacity="',
//                 opacity,
//                 '"',
//                 filter,
//                 "/>"
//             );
//     }

//     function _highlight(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         bool pulse,
//         bool glitch
//     ) internal pure returns (string memory) {
//         string memory base = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="white" stroke-width="2" opacity="0.9"',
//             glitch ? ' filter="url(#glitch)"' : ""
//         );

//         return
//             pulse
//                 ? string.concat(
//                     base,
//                     '><animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/><animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/></circle>'
//                 )
//                 : string.concat(base, "/>");
//     }

//     function _strokeWidth(uint8 size) internal pure returns (uint8) {
//         if (size < 15) return 2;
//         uint256 calc = (uint256(size) * 4) / 60;
//         return uint8(calc < 2 ? 2 : calc > 15 ? 15 : calc);
//     }
// }
// pragma solidity ^0.8.26;

// import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// interface INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure returns (string memory);
// }

// contract NeonPortal is INeonPortal {
//     function createNeonPortal(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint256 seed,
//         bool enablePulse
//     ) external pure override returns (string memory) {
//         // Ensure minimum size to prevent underflow
//         if (size < 20) size = 20;

//         // Determine if this portal should have glitch effect
//         bool enableGlitch = (seed % 5) == 0; // 20% chance

//         return
//             string.concat(
//                 _createPortalDefs(seed),
//                 "<g>",
//                 _createCloudBase(x, y, size),
//                 _createNeonRing(x, y, size, enablePulse, enableGlitch),
//                 "</g>"
//             );
//     }

//     // === DEFINITIONS ===
//     function _createPortalDefs(
//         uint256 seed
//     ) internal pure returns (string memory) {
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
//                 // NEW: Horizontal-stripe glitch filter
//                 _createGlitchFilter(seed),
//                 "</defs>"
//             );
//     }

//     // === GLITCH FILTER ===
//     function _createGlitchFilter(
//         uint256 seed
//     ) internal pure returns (string memory) {
//         return
//             string.concat(
//                 '<filter id="glitchShift" x="-20%" y="-20%" width="140%" height="140%">',
//                 // 1. horizontal noise (only varies in Y)
//                 '<feTurbulence type="fractalNoise" baseFrequency="0 0.9" numOctaves="2" seed="',
//                 Strings.toString(seed % 10000), // cheap uniqueness
//                 '" result="t"/>',
//                 // 2. hard-edge bars (values > 0 → 1, else 0)
//                 '<feColorMatrix in="t" type="matrix" values="1 0 0 0 -0.5  0 1 0 0 -0.5  0 0 1 0 -0.5  0 0 0 1 0" result="bars"/>',
//                 // 3. keep only the red channel as a 1-bit mask
//                 '<feComponentTransfer in="bars" result="mask">',
//                 '<feFuncR type="table" tableValues="0 1"/>',
//                 "</feComponentTransfer>",
//                 // 4. shove white bars along X
//                 '<feDisplacementMap in="SourceGraphic" in2="mask" scale="18" xChannelSelector="R" yChannelSelector="R"/>',
//                 "</filter>"
//             );
//     }

//     // === CLOUD BASE ===
//     function _createCloudBase(
//         uint16 x,
//         uint16 y,
//         uint8 size
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
//         uint8 size,
//         bool enablePulse,
//         bool enableGlitch
//     ) internal pure returns (string memory) {
//         uint8 strokeWidth = _getStrokeWidth(size);

//         if (enableGlitch) {
//             return
//                 string.concat(
//                     // Wide outer glow layer with glitch
//                     _createWideGlowLayerGlitch(x, y, size, strokeWidth),
//                     // Medium glow layer with glitch
//                     _createGlowLayerGlitch(x, y, size, strokeWidth),
//                     // Main ring layer with glitch
//                     _createMainRingLayerGlitch(x, y, size, strokeWidth),
//                     // Inner highlight layer with glitch
//                     _createHighlightLayerGlitch(x, y, size, enablePulse)
//                 );
//         } else {
//             return
//                 string.concat(
//                     // Standard layers (no glitch)
//                     _createWideGlowLayer(x, y, size, strokeWidth),
//                     _createGlowLayer(x, y, size, strokeWidth),
//                     _createMainRingLayer(x, y, size, strokeWidth),
//                     _createHighlightLayer(x, y, size, enablePulse)
//                 );
//         }
//     }

//     // === WIDE GLOW LAYER GLITCH ===
//     function _createWideGlowLayerGlitch(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         uint8 wideStrokeWidth = strokeWidth;
//         if (strokeWidth <= 5) {
//             wideStrokeWidth = strokeWidth * 3;
//         } else {
//             wideStrokeWidth = 15;
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
//                 Strings.toString(wideStrokeWidth),
//                 '" filter="url(#glitchShift)" opacity="0.5"/>'
//             );
//     }

//     // === GLOW LAYER GLITCH ===
//     function _createGlowLayerGlitch(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         uint8 mediumStrokeWidth = strokeWidth;
//         if (strokeWidth <= 5) {
//             mediumStrokeWidth = strokeWidth * 2;
//         } else {
//             mediumStrokeWidth = 10;
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
//                 Strings.toString(mediumStrokeWidth),
//                 '" filter="url(#glitchShift)" opacity="0.7"/>'
//             );
//     }

//     // === MAIN RING LAYER GLITCH ===
//     function _createMainRingLayerGlitch(
//         uint16 x,
//         uint16 y,
//         uint8 size,
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
//                 '" filter="url(#glitchShift)"/>'
//             );
//     }

//     // === HIGHLIGHT LAYER GLITCH ===
//     function _createHighlightLayerGlitch(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         bool enablePulse
//     ) internal pure returns (string memory) {
//         string memory baseHighlight = string.concat(
//             '<circle cx="',
//             Strings.toString(x),
//             '" cy="',
//             Strings.toString(y),
//             '" r="',
//             Strings.toString(size),
//             '" fill="none" stroke="white" stroke-width="2" opacity="0.9" filter="url(#glitchShift)"'
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

//     // === WIDE GLOW LAYER ===
//     function _createWideGlowLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
//         uint8 strokeWidth
//     ) internal pure returns (string memory) {
//         // Much thicker stroke for wider glow effect
//         uint8 wideStrokeWidth = strokeWidth;
//         if (strokeWidth <= 5) {
//             wideStrokeWidth = strokeWidth * 3;
//         } else {
//             wideStrokeWidth = 15;
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
//                 Strings.toString(wideStrokeWidth),
//                 '" filter="url(#blur)" opacity="0.5"/>'
//             );
//     }

//     // === GLOW LAYER ===
//     function _createGlowLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
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
//                 '" filter="url(#blur)" opacity="0.7"/>'
//             );
//     }

//     // === MAIN RING LAYER ===
//     function _createMainRingLayer(
//         uint16 x,
//         uint16 y,
//         uint8 size,
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
//         uint8 size,
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
//     function _getStrokeWidth(uint8 size) internal pure returns (uint8) {
//         // Follow the same pattern as other shape contracts
//         if (size < 15) return 2; // Minimum stroke width

//         uint256 calculation = (uint256(size) * 4) / 60;
//         if (calculation < 2) return 2;
//         if (calculation > 15) return 15; // Cap at 15 for portals
//         return uint8(calculation);
//     }
// }
// // pragma solidity ^0.8.26;

// // import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

// // interface INeonPortal {
// //     function createNeonPortal(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         uint256 seed,
// //         bool enablePulse
// //     ) external pure returns (string memory);
// // }

// // contract NeonPortal is INeonPortal {
// //     function createNeonPortal(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         uint256 seed,
// //         bool enablePulse
// //     ) external pure override returns (string memory) {
// //         // Ensure minimum size to prevent underflow
// //         if (size < 20) size = 20;

// //         return
// //             string.concat(
// //                 _createPortalDefs(),
// //                 "<g>",
// //                 // _createCloudBase(x, y, size),
// //                 _createNeonRing(x, y, size, enablePulse),
// //                 "</g>"
// //             );
// //     }

// //     // === DEFINITIONS ===
// //     function _createPortalDefs() internal pure returns (string memory) {
// //         return
// //             string.concat(
// //                 "<defs>",
// //                 // Multiple offset radial gradients for organic clouds
// //                 '<radialGradient id="portalBg1" cx="0.3" cy="0.2">',
// //                 '<stop offset="0" stop-color="#FF00FF" stop-opacity="0.9"/>',
// //                 '<stop offset="0.6" stop-color="#8000FF" stop-opacity="0.4"/>',
// //                 '<stop offset="1" stop-color="#004080" stop-opacity="0.1"/>',
// //                 "</radialGradient>",
// //                 '<radialGradient id="portalBg2" cx="0.7" cy="0.8">',
// //                 '<stop offset="0" stop-color="#00FFFF" stop-opacity="0.8"/>',
// //                 '<stop offset="0.5" stop-color="#4080FF" stop-opacity="0.3"/>',
// //                 '<stop offset="1" stop-color="#000040" stop-opacity="0.1"/>',
// //                 "</radialGradient>",
// //                 '<radialGradient id="portalBg3" cx="0.1" cy="0.9">',
// //                 '<stop offset="0" stop-color="#FF40FF" stop-opacity="0.7"/>',
// //                 '<stop offset="0.8" stop-color="#200040" stop-opacity="0.2"/>',
// //                 '<stop offset="1" stop-color="#000000" stop-opacity="0.05"/>',
// //                 "</radialGradient>",
// //                 // Ring gradient (cyan to magenta)
// //                 '<linearGradient id="portalRing">',
// //                 '<stop offset="0" stop-color="#00FFFF"/>',
// //                 '<stop offset="1" stop-color="#FF00FF"/>',
// //                 "</linearGradient>",
// //                 "</defs>"
// //             );
// //     }

// //     // === CLOUD BASE ===
// //     function _createCloudBase(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size
// //     ) internal pure returns (string memory) {
// //         // Create multiple cloud layers with different sizes and positions
// //         // Use safe arithmetic to prevent overflow/underflow
// //         uint16 cloudSize1 = size * 3; // Reduced multiplier
// //         uint16 cloudSize2 = size * 2; // Reduced multiplier
// //         uint16 cloudSize3 = size * 3; // Reduced multiplier

// //         // Safe offset calculations - check bounds before arithmetic
// //         uint16 pos1X = x > 50 ? x - 50 : 0;
// //         uint16 pos1Y = y > 80 ? y - 80 : 0;

// //         // For additions, check if result would exceed uint16 max
// //         uint16 pos2X = x < 1380 ? x + 60 : 1380; // 1440 - 60 = 1380
// //         uint16 pos2Y = y < 1400 ? y + 40 : 1400; // 1440 - 40 = 1400

// //         uint16 pos3X = x > 30 ? x - 30 : 0;
// //         uint16 pos3Y = y < 1370 ? y + 70 : 1370; // 1440 - 70 = 1370

// //         return
// //             string.concat(
// //                 // Layer 1: Main magenta cloud (offset up-left)
// //                 '<circle cx="',
// //                 Strings.toString(pos1X),
// //                 '" cy="',
// //                 Strings.toString(pos1Y),
// //                 '" r="',
// //                 Strings.toString(cloudSize1),
// //                 '" fill="url(#portalBg1)" filter="url(#blur)"/>',
// //                 // Layer 2: Cyan cloud (offset down-right)
// //                 '<circle cx="',
// //                 Strings.toString(pos2X),
// //                 '" cy="',
// //                 Strings.toString(pos2Y),
// //                 '" r="',
// //                 Strings.toString(cloudSize2),
// //                 '" fill="url(#portalBg2)" filter="url(#blur)"/>',
// //                 // Layer 3: Purple accent cloud (offset down-left)
// //                 '<circle cx="',
// //                 Strings.toString(pos3X),
// //                 '" cy="',
// //                 Strings.toString(pos3Y),
// //                 '" r="',
// //                 Strings.toString(cloudSize3),
// //                 '" fill="url(#portalBg3)" filter="url(#blur)"/>'
// //             );
// //     }

// //     // === NEON RING ===
// //     function _createNeonRing(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         bool enablePulse
// //     ) internal pure returns (string memory) {
// //         uint8 strokeWidth = _getStrokeWidth(size);

// //         return
// //             string.concat(
// //                 // Wide outer glow layer (like red circles)
// //                 _createWideGlowLayer(x, y, size, strokeWidth),
// //                 // Medium glow layer
// //                 _createGlowLayer(x, y, size, strokeWidth),
// //                 // Main ring layer
// //                 _createMainRingLayer(x, y, size, strokeWidth),
// //                 // Inner highlight layer
// //                 _createHighlightLayer(x, y, size, enablePulse)
// //             );
// //     }

// //     // === WIDE GLOW LAYER (NEW) ===
// //     function _createWideGlowLayer(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         uint8 strokeWidth
// //     ) internal pure returns (string memory) {
// //         // Much thicker stroke for wider glow effect
// //         uint8 wideStrokeWidth = strokeWidth * 3;
// //         if (wideStrokeWidth > 20) wideStrokeWidth = 20;

// //         return
// //             string.concat(
// //                 '<circle cx="',
// //                 Strings.toString(x),
// //                 '" cy="',
// //                 Strings.toString(y),
// //                 '" r="',
// //                 Strings.toString(size),
// //                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
// //                 Strings.toString(wideStrokeWidth),
// //                 '" filter="url(#blur)" opacity="0.4"/>'
// //             );
// //     }

// //     // === GLOW LAYER ===
// //     function _createGlowLayer(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         uint8 strokeWidth
// //     ) internal pure returns (string memory) {
// //         // Safe multiplication - ensure no overflow
// //         uint8 glowStrokeWidth = strokeWidth;
// //         if (strokeWidth <= 5) {
// //             glowStrokeWidth = strokeWidth * 2; // Reduced multiplier
// //         } else {
// //             glowStrokeWidth = 10; // Lower cap
// //         }

// //         return
// //             string.concat(
// //                 '<circle cx="',
// //                 Strings.toString(x),
// //                 '" cy="',
// //                 Strings.toString(y),
// //                 '" r="',
// //                 Strings.toString(size),
// //                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
// //                 Strings.toString(glowStrokeWidth),
// //                 '" filter="url(#blur)" opacity="0.6"/>'
// //             );
// //     }

// //     // === MAIN RING LAYER ===
// //     function _createMainRingLayer(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         uint8 strokeWidth
// //     ) internal pure returns (string memory) {
// //         return
// //             string.concat(
// //                 '<circle cx="',
// //                 Strings.toString(x),
// //                 '" cy="',
// //                 Strings.toString(y),
// //                 '" r="',
// //                 Strings.toString(size),
// //                 '" fill="none" stroke="url(#portalRing)" stroke-width="',
// //                 Strings.toString(strokeWidth),
// //                 '"/>'
// //             );
// //     }

// //     // === HIGHLIGHT LAYER ===
// //     function _createHighlightLayer(
// //         uint16 x,
// //         uint16 y,
// //         uint16 size,
// //         bool enablePulse
// //     ) internal pure returns (string memory) {
// //         string memory baseHighlight = string.concat(
// //             '<circle cx="',
// //             Strings.toString(x),
// //             '" cy="',
// //             Strings.toString(y),
// //             '" r="',
// //             Strings.toString(size),
// //             '" fill="none" stroke="white" stroke-width="2" opacity="0.9"'
// //         );

// //         if (enablePulse) {
// //             return
// //                 string.concat(
// //                     baseHighlight,
// //                     ">",
// //                     '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="2s" repeatCount="indefinite"/>',
// //                     '<animate attributeName="stroke-width" values="1;3;1" dur="2s" repeatCount="indefinite"/>',
// //                     "</circle>"
// //                 );
// //         } else {
// //             return string.concat(baseHighlight, "/>");
// //         }
// //     }

// //     // === UTILITY FUNCTIONS ===
// //     function _getStrokeWidth(uint16 size) internal pure returns (uint8) {
// //         // Follow the same pattern as other shape contracts
// //         if (size < 15) return 2; // Minimum stroke width

// //         uint256 calculation = (uint256(size) * 4) / 60;
// //         if (calculation < 2) return 2;
// //         if (calculation > 15) return 15; // Cap at 15 for portals
// //         return uint8(calculation);
// //     }
// // }
