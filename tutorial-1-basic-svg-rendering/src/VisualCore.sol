// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IVisualCore {
    function createAllFilters(
        uint256 seed
    ) external pure returns (string memory);

    function generateBackground(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function createFrames() external pure returns (string memory);

    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory);

    function generateRandomText(
        uint256 seed,
        uint8 length
    ) external pure returns (string memory);
}

contract VisualCore is IVisualCore {
    string internal constant CF = 'class="f"';
    string internal constant BLR = 'filter="url(#blur)"';
    string internal constant REP = 'repeatCount="indefinite"';
    string private constant FONT_BASE64 =
        "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";

    function createAllFilters(
        uint256 seed
    ) external pure override returns (string memory) {
        return
            string.concat(
                "<defs>",
                _createOriginalBlurFilter(),
                _createNeonPortalGradients(),
                _createFrameGradients(seed), // Inline frame gradients
                "</defs>"
            );
    }

    function _createOriginalBlurFilter() internal pure returns (string memory) {
        return
            string.concat(
                '<filter id="blur" filterUnits="userSpaceOnUse" x="-720" y="-720" width="2160" height="2160">',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="5" result="tight"/>',
                '<feColorMatrix in="tight" type="matrix" values="6 0 0 0 0 0 6 0 0 0 0 0 6 0 0 0 0 0 1.0 0" result="tightColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="15" result="medium"/>',
                '<feColorMatrix in="medium" type="matrix" values="4 0 0 0 0 0 4 0 0 0 0 0 4 0 0 0 0 0 0.8 0" result="mediumColored"/>',
                '<feGaussianBlur in="SourceGraphic" stdDeviation="35" result="wide"/>',
                '<feColorMatrix in="wide" type="matrix" values="2 0 0 0 0 0 2 0 0 0 0 0 2 0 0 0 0 0 0.6 0" result="wideColored"/>',
                "<feMerge>",
                '<feMergeNode in="wideColored"/>',
                '<feMergeNode in="mediumColored"/>',
                '<feMergeNode in="tightColored"/>',
                '<feMergeNode in="SourceGraphic"/>',
                "</feMerge>",
                "</filter>"
            );
    }

    function _createNeonPortalGradients()
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                '<linearGradient id="ring"><stop offset="0" stop-color="#00FFFF"/><stop offset="1" stop-color="#FF00FF"/></linearGradient>',
                '<radialGradient id="b1"><stop offset="0" stop-color="#004080" stop-opacity="0.3"/><stop offset="0.6" stop-color="#002040" stop-opacity="0.15"/><stop offset="1" stop-color="#000000" stop-opacity="0.02"/></radialGradient>',
                '<radialGradient id="b2"><stop offset="0" stop-color="#800040" stop-opacity="0.25"/><stop offset="0.7" stop-color="#400020" stop-opacity="0.1"/><stop offset="1" stop-color="#000000" stop-opacity="0.01"/></radialGradient>',
                '<radialGradient id="b3"><stop offset="0" stop-color="#408080" stop-opacity="0.2"/><stop offset="0.8" stop-color="#204040" stop-opacity="0.08"/><stop offset="1" stop-color="#000000" stop-opacity="0.005"/></radialGradient>'
            );
    }

    function generateBackground(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) external pure override returns (string memory) {
        return _createMirroredBackground(colorA, colorB, tokenId);
    }

    //_TEXT
    function _createSingleText(
        int16 x,
        int16 y,
        uint8 fontSize,
        string memory fill,
        string memory opacity,
        string memory animOpacity,
        string memory content
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<text x="',
                _intToString(x),
                '" y="',
                _intToString(y),
                '" ',
                CF,
                ' font-size="',
                Strings.toString(fontSize),
                '" fill="',
                fill,
                '" opacity="',
                opacity,
                '" ',
                BLR,
                ">",
                // '<animate attributeName="opacity" values="',
                // animOpacity,
                // '" dur="8s" ',
                // REP,
                // "/>",
                content,
                "</text>"
            );
    }

    function _createTextCluster(
        string memory colorB,
        int16 baseX,
        int16 baseY,
        uint256 seed
    ) internal pure returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(seed + 77777);

        string memory part1 = _createSingleText(
            baseX + int16(Random.randRange(ctx, -150, 150)),
            baseY + int16(Random.randRange(ctx, -120, 120)),
            60 + uint8(Random.randInt(ctx) % 40),
            colorB,
            "0.1",
            "0.1;0.29;0.1",
            "GHZGHZ"
        );

        string memory part2 = _createSingleText(
            baseX + int16(Random.randRange(ctx, -200, 200)),
            baseY + int16(Random.randRange(ctx, -180, 180)),
            50 + uint8(Random.randInt(ctx) % 50),
            colorB,
            "0.07",
            "0.07;0.25;0.07",
            "HZZGHH"
        );

        string memory part3 = _createSingleText(
            baseX + int16(Random.randRange(ctx, -170, 170)),
            baseY + int16(Random.randRange(ctx, -150, 150)),
            70 + uint8(Random.randInt(ctx) % 30),
            colorB,
            "0.09",
            "0.09;0.3;0.09",
            "ZGHHZG"
        );

        return string.concat(part1, part2, part3);
    }

    function _createMirroredGroups(
        string memory cluster,
        uint256 seed
    ) internal pure returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(seed + 99999);
        uint256 choice = Random.randInt(ctx) % 2;

        string memory output = string.concat(
            '<g transform="scale(',
            choice == 0 ? "-1,1" : "1,-1",
            ") translate(",
            choice == 0 ? "-1440,0" : "0,-1440",
            ')">',
            cluster,
            "</g>"
        );

        int16[4] memory offsets = choice == 0
            ? [int16(-300), int16(300), int16(0), int16(0)]
            : [int16(0), int16(0), int16(-250), int16(250)];

        int16[4] memory orthos = choice == 0
            ? [int16(0), int16(0), int16(-250), int16(250)]
            : [int16(-300), int16(300), int16(0), int16(0)];

        for (uint8 i = 0; i < 4; i++) {
            output = string.concat(
                output,
                '<g transform="translate(',
                _intToString(offsets[i]),
                ",",
                _intToString(orthos[i]),
                ')">',
                cluster,
                "</g>"
            );
        }

        return output;
    }

    function _createGrid(
        string memory colorA
    ) internal pure returns (string memory) {
        string memory lines = "";

        for (uint16 i = 30; i <= 720; i += 30) {
            string memory iStr = Strings.toString(i);
            string memory hLine = string.concat(
                '<line x1="',
                iStr,
                '" y1="0" x2="',
                iStr,
                '" y2="720" stroke="',
                colorA,
                '" stroke-width="1" opacity="0.35" ',
                // BLR,
                "/>"
            );
            string
                memory hAnim = '<animate attributeName="opacity" values="0.35;0.15;0.35" dur="8s" ';
            string memory vLine = string.concat(
                '<line x1="0" y1="',
                iStr,
                '" x2="720" y2="',
                iStr,
                '" stroke="',
                colorA,
                '" stroke-width="1" opacity="0.35" ',
                // BLR,
                "/>"
            );
            lines = string.concat(
                lines,
                hLine,
                // hAnim,
                REP,
                "/>",
                vLine,
                // hAnim,
                REP,
                "/>"
            );
        }

        string memory group = string.concat("<g>", lines, "</g>");
        return
            string.concat(
                group,
                '<g transform="scale(-1,1) translate(-1440,0)">',
                group,
                "</g>",
                '<g transform="scale(1,-1) translate(0,-1440)">',
                group,
                "</g>",
                '<g transform="scale(-1,-1) translate(-1440,-1440)">',
                group,
                "</g>"
            );
    }

    function generateTextStyle(
        string memory colorA,
        string memory colorB
    ) external pure returns (string memory) {
        return
            string.concat(
                "<defs><style>",
                ":root{--colorA:",
                colorA,
                ";--colorB:",
                colorB,
                ";}",
                "@font-face{font-family:'f';src:url(data:font/woff2;base64,",
                FONT_BASE64,
                ") format('woff2');}",
                ".f{font-family:'f',monospace}",
                "</style></defs>"
            );
    }

    function generateRandomText(
        uint256 seed,
        uint8 length
    ) external pure override returns (string memory) {
        bytes memory chars = "ZRB"; // Only the 3 working characters
        bytes memory text = new bytes(length);

        uint256 s = seed;
        for (uint8 i = 0; i < length; i++) {
            text[i] = chars[s % 3]; // Only 3 chars available
            s = s >> 2; // Shift by 2 bits since we only have 3 options
        }

        return string(text);
    }

    function _createMirroredBackground(
        string memory colorA,
        string memory colorB,
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<rect width="1440" height="1440" fill="black"/>',
                _createGrid(colorA),
                _createTestText(colorB, seed)
            );
    }

    function _createTestText(
        string memory colorB,
        uint256 seed
    ) internal pure returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(seed + 88888);

        int16 baseX = 720 + int16(Random.randRange(ctx, -300, 300));
        int16 baseY = 720 + int16(Random.randRange(ctx, -300, 300));
        int16 spread1X = int16(Random.randRange(ctx, -250, 250));
        int16 spread1Y = int16(Random.randRange(ctx, -200, 200));

        string memory textCluster = _createTextCluster(
            colorB,
            baseX,
            baseY,
            seed
        );

        // Cluster + one spread copy
        string memory baseSpread = string.concat(
            "<g>",
            textCluster,
            "</g>",
            '<g transform="translate(',
            _intToString(spread1X),
            ",",
            _intToString(spread1Y),
            ')">',
            textCluster,
            "</g>"
        );

        // Inline mirror logic (was _createSelectiveMirrors)
        uint256 mirrorChoice = Random.randInt(ctx) % 2;

        string memory mirrors;
        if (mirrorChoice == 0) {
            // Horizontal emphasis
            mirrors = string.concat(
                '<g transform="scale(-1,1) translate(-1440,0)">',
                textCluster,
                "</g>",
                '<g transform="translate(-300,0)">',
                textCluster,
                "</g>",
                '<g transform="translate(300,0)">',
                textCluster,
                "</g>",
                '<g transform="translate(0,-250)">',
                textCluster,
                "</g>",
                '<g transform="translate(0,250)">',
                textCluster,
                "</g>"
            );
        } else {
            // Vertical emphasis
            mirrors = string.concat(
                '<g transform="scale(1,-1) translate(0,-1440)">',
                textCluster,
                "</g>",
                '<g transform="translate(0,-300)">',
                textCluster,
                "</g>",
                '<g transform="translate(0,300)">',
                textCluster,
                "</g>",
                '<g transform="translate(-250,0)">',
                textCluster,
                "</g>",
                '<g transform="translate(250,0)">',
                textCluster,
                "</g>"
            );
        }

        return string.concat(baseSpread, mirrors);
    }

    // === FRAMES ===
    function createFrames()
        external
        pure
        override
        returns (
            // string memory colorA,
            // string memory colorB
            string memory
        )
    {
        return
            string.concat(
                _createFrame(30, 30, 1380, 1380, "outerFrameGrad"),
                _createFrame(60, 60, 1320, 1320, "innerFrameGrad")
            );
    }

    function _createFrame(
        uint16 x,
        uint16 y,
        uint16 width,
        uint16 height,
        string memory gradientId
    ) internal pure returns (string memory) {
        string memory xStr = Strings.toString(x);
        string memory yStr = Strings.toString(y);
        string memory wStr = Strings.toString(width);
        string memory hStr = Strings.toString(height);

        string memory baseRect = string.concat(
            '<rect x="',
            xStr,
            '" y="',
            yStr,
            '" width="',
            wStr,
            '" height="',
            hStr,
            '" fill="none" stroke="url(#',
            gradientId
        );

        string memory layer1 = string.concat(
            baseRect,
            ')" stroke-width="30" filter="url(#blur)" opacity="0.5"/>'
        );
        string memory layer2 = string.concat(
            baseRect,
            ')" stroke-width="20" filter="url(#blur)" opacity="0.7"/>'
        );
        string memory layer3 = string.concat(
            baseRect,
            ')" stroke-width="10"/>'
        );

        string memory animRect = string.concat(
            '<rect x="',
            xStr,
            '" y="',
            yStr,
            '" width="',
            wStr,
            '" height="',
            hStr,
            '" fill="none" stroke="white" stroke-width="1" filter="url(#blur)" opacity="0.9">',
            '<animate attributeName="opacity" values="0.3;0.9;0.3" dur="3s" repeatCount="indefinite"/>',
            '<animate attributeName="stroke-width" values="0.5;3;0.5" dur="3s" repeatCount="indefinite"/>',
            "</rect>"
        );

        return string.concat(layer1, layer2, layer3, animRect);
    }

    function _createFrameGradients(
        uint256 seed
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<linearGradient id="outerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="var(--colorB)"/>',
                '<stop offset="0.5" stop-color="var(--colorA)"/>',
                '<stop offset="1" stop-color="var(--colorB)"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="0 0.5 0.5;360 0.5 0.5" dur="8s" repeatCount="indefinite"/>',
                "</linearGradient>",
                '<linearGradient id="innerFrameGrad" x1="0" y1="0" x2="1" y2="1">',
                '<stop offset="0" stop-color="var(--colorA)"/>',
                '<stop offset="0.5" stop-color="var(--colorB)"/>',
                '<stop offset="1" stop-color="var(--colorA)"/>',
                '<animateTransform attributeName="gradientTransform" type="rotate" values="360 0.5 0.5;0 0.5 0.5" dur="10s" repeatCount="indefinite"/>',
                "</linearGradient>"
            );
    }

    // Utility function to convert int to string (handles negative values)
    function _intToString(int16 value) internal pure returns (string memory) {
        if (value >= 0) {
            return Strings.toString(uint256(int256(value)));
        } else {
            return
                string.concat("-", Strings.toString(uint256(int256(-value))));
        }
    }
}
