// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {InflateLib} from "./utils/InflateLib.sol"; // same tiny inflate lib
import {UploadTspansDef} from "./UploadTspansDef.sol";
import {Random, RandomCtx} from "./utils/Random.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract OnChainArt is ERC721 {
    struct Blob {
        address ptr;
        uint32 rawLen;
    }
    Blob[3] private blobs; // packed pointers + raw lengths

    constructor(UploadTspansDef store) ERC721("On-chain Art", "ART") {
        (blobs[0].ptr, blobs[0].rawLen) = store.getBlob(0);
        (blobs[1].ptr, blobs[1].rawLen) = store.getBlob(1);
        (blobs[2].ptr, blobs[2].rawLen) = store.getBlob(2);
    }

    // 9.2 font
    string constant LOCAL_FONT_DATA_GHZ =
        "d09GMgABAAAAAAaUABAAAAAADsQAAAY2AAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP0ZGVE0cGh4GYACCeggYCYRlEQgKgniCdAsuAAE2AiQDWAQgBYonB4FUDIEgG3kNo5FRJxglM7K/TETj8Itd2Dcoo1Dk6EYRyrX84v2ZnFg1mya3E53ofsv2Bf/wdn2d+94rdH3rDVg1Tmd3+1sz3UuEVCRkYjSuXiJjLLhCmvsfoXloABy65Vd0a2e7Ha+4zglcBDyCwWM/pqtwnWs5ueh/tWNwnLiRmpAkTJx6A1QoFJGSy43C9p/2Y9a7L6gkKg/REiBrJXtIX5DPPcw+h5lnSvMQxazNJK6U1cWyUFfztn/PKssrOLFgqmwnf++/BhDAR/ekIwAfd9x2JcAn50d/CqgGWgGDEC0IBxjAuFndTIBzOAAcDnBwqm4DcAAAIAAAgJHFpQWK+DX/BEAM6730/wHEAB4BFrBANwLgHCwCunGUgEbqsRg8YxzJvT7xW/xxa/4B8IxuyyjwB33sGfud9kHvf/L+I291ILwACkEkRgYwxFxgidIF/EMhUphHdDN7rQ2Wzb5xYbAL38hQ0JCT5TRNMjXnTJwXsOqIGmFaGo3td34c8oqaNtcKyvw31ekmTDa54rMWWrDZGTWhOOdKsVxwWbYd1PTA/4yuNJX+71mlKcFOD0bOi8py1MrGM7Kao48shFllpa6eK+GvPvroJpQ3EaG42rLYOc4a+2Wwp1YXMn9cwa2fDI9dM26CWzsBc6U85doTvNxzoKkazVwTF/TK0pOGFVeb1XVFranK/HNb7led+R5RerSLzNvc9r647O1k19KwGlIVsiWjSGZbznBVVcwKzqGIOdFc0jl2CqjpsZZkx9H3Gm3Ke04uuNk2LrDcLNQkbXXZKnmvuNHEl1fDboHKpczd2nHLVT7Hr111QmIdNU+1Wf0+oI1Gw0x8Xq6x9iwtw2DJVic0qGzKJB12VZ9lT+zZxVHuhTnSvAs9szk7o6jiwFRl8vF6YsZawtzlkrzDQsl2BFYNNIGoMoTi9k6neK5PmjqVl9wffxIdp7RozJaMENNg9L0KNxH6H3UAtAKQASHQB2wDABzwMgYAkAgt15Bz1S5U1cV1F55YU6g+LqiTiCO1OUHDtr7e9UINESz74fC3d+tbN+/Zs08Ye0GFfSaWidlHzNpd1yfYlQFARWzZ+WDkkm+3V8LgnYW1NYosWCFofDAKq/4BUa0PJpCOrKTOebCjgvkywwtFqrx6S568lpvtlUL4Ze62P1hIkvShYiEqCFZYWCXsX6lRytZtPAikKioncZW8VrFCH2KQAgmfXDwJDZOAuJIHjStNMFJE9bsFa+9+8oHj6nb+Wl/MDeH2QLw3BogxAAhi/n8jDImZ/jCc02q+YQjA7IU43tg7zLPL0+CAA5LTUFOg5SGl9TbgTEUP578gfl4r1RgADMLQCoIJAKBFBgHQxAbAIlcAzmPDEkTCPWCoZQ9YEh4DRycvQEArb0NIwo8QsYu/ISbTPBSo16WQcK1ugCquMG1QzTnmFqhhwFZBEwt2Gl6k1d4DL7HVPgIvU2s/9XyFdvtztzctna7qR0T5E6nkf26svxv+miPWYlAa0io3UAzQkR4oJpPrqh6U5MIAmOekE9IAW4RsscOy757c376/ukDs548FIDVAicYEqErwaxOqiMxz3GI7/8gtvpBbqkUqbLK6HODoP1Ralr0lET5hWrwLO9p8G2Vj0zBOwEojNseiLMwaSdjMuUyfWMGClYNNrY8ICGDpQtDTcjeZL77l1zGD8ISWEWa2tVQrEA34Kzifvw7MHJPMeJqWTS2Qd8FRgdHxsdo2ewSU3CMaLiy1MohK6YSKTA9JNC3zszkW8C2Ee1zTYHE80diZ5PjCLGInTbxbo+3PA6jkQGNJnMmSAyPWYlAaSKvcAMVwuMV+Iib/SLuWcvzyH0tQ9mSPatwf+444Ypcdup1yJuLu8UsZWhLftUo8rI7o4Kg8tg1AvcktUimG+DR40b7KfkgrExlZLBtxONWsAoWKFKugRFWqVo1qVad6rWg15PlQi2gyfGvBljIML0MwtiBFliN5S96Wd+RdeU/elw/kQ+nSbutO2lXU212HXuv/ct3AZB7PlU6kG8uVkee5rtSXl2leUCuvKPewtd3R3pcbP4xNh4Y+/fAtxn6BqUVc2amJBAsi3J3bUVbJwxxCJIZVFTtyHtKYhCmrrGAvjiOrg+YUAA==";
    // 8.75 font
    string constant LOCAL_FONT_DATA_RGH =
        "T1RUTwAJAIAAAwAQQ0ZGIFRxXHkAAARQAAABm09TLzJzdHMGAAABAAAAAGBjbWFwAOQAjQAAA+wAAABEaGVhZDDAnVwAAACcAAAANmhoZWEUAAlbAAAA1AAAACRobXR4K3sEqQAABewAAAAUbWF4cAAFUAAAAAD4AAAABm5hbWX5agBpAAABYAAAAotwb3N0AAMAAAAABDAAAAAgAAEAAAABAACB7DtrXw889QADCAAAAAAA5IAoMgAAAADkgCgyAAAAAAiqCAAAAAADAAIAAAAAAAAAAQAACAAAAAAACVUAAAAAC/8AAQAAAAAAAAAAAAAAAAAAAAUAAFAAAAUAAAADCLIB9AAFAAACigK7AAAAjAKKArsAAAHfADEBAgAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAABYWFhYAEAAIABSCAAAAAAACAAAAAAAAAEAAAAABAAIAAAgACAAAAAAACIBngABAAAAAAAAAAEAOQABAAAAAAABAAkAAAABAAAAAAACAAcAGwABAAAAAAADABMAtAABAAAAAAAEABEAMAABAAAAAAAFAAsAkwABAAAAAAAGABAAYwABAAAAAAAHAAEAOQABAAAAAAAIAAEAOQABAAAAAAAJAAEAOQABAAAAAAAKAAEAOQABAAAAAAALAAEAOQABAAAAAAAMAAEAOQABAAAAAAANAAEAOQABAAAAAAAOAAEAOQABAAAAAAAQAAkAAAABAAAAAAARAAcAGwADAAEECQAAAAIAUwADAAEECQABABIACQADAAEECQACAA4AIgADAAEECQADACYAxwADAAEECQAEACIAQQADAAEECQAFABYAngADAAEECQAGACAAcwADAAEECQAHAAIAUwADAAEECQAIAAIAUwADAAEECQAJAAIAUwADAAEECQAKAAIAUwADAAEECQALAAIAUwADAAEECQAMAAIAUwADAAEECQANAAIAUwADAAEECQAOAAIAUwADAAEECQAQABIACQADAAEECQARAA4AImJyYWlsbGUyMwBiAHIAYQBpAGwAbABlADIAM1JlZ3VsYXIAUgBlAGcAdQBsAGEAcmJyYWlsbGUyMyBSZWd1bGFyAGIAcgBhAGkAbABsAGUAMgAzACAAUgBlAGcAdQBsAGEAcmJyYWlsbGUyM1JlZ3VsYXIAYgByAGEAaQBsAGwAZQAyADMAUgBlAGcAdQBsAGEAclZlcnNpb24gMC4xAFYAZQByAHMAaQBvAG4AIAAwAC4AMSA6YnJhaWxsZTIzIFJlZ3VsYXIAIAA6AGIAcgBhAGkAbABsAGUAMgAzACAAUgBlAGcAdQBsAGEAcgAAAAABAAMAAQAAAAwABAA4AAAACgAIAAIAAgAgAEcASABS//8AAAAgAEcASABS////4f+7/7v/sgABAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAEAQABAQERYnJhaWxsZTIzUmVndWxhcgABAQFD+BsA+BwC+B0D+B4Ei4scCAAcCVUFHQAAAJcPHQAAAKARix0AAAGbEh4KAASIKBJfHg8eDx4KAASIKBJfHg8eDwwHAAUBAQwdJi0tVmVyc2lvbiAwLjFicmFpbGxlMjMgUmVndWxhcmJyYWlsbGUyM1JlZ3VsYXIAAAABiwGLAYsBiwAFAQFucqvG8xwG0tC9FRwFnYsF/WP6TgX9Yv5OBXgcB4gVixz4iwX5YvpPBf1i+k4F+Yj+ThX5Y/5PBYscB3UF/WP+TgX9dfpiFfli/k8F+WP6TwUc+mOLBRwF4hz4MhUc+dmLBYscCAAFHAYniwWLHPgABQ4cCKoOHAlVHAYAixX9P4sFi/k+Bf0/iwWL+T8F+T+LBYv5PwX5P4sFi/0/Bfk+iwWL/T8F/T6LBYv9PgUOHAlVHAYAixX9P4sFixwIAAX5P4sFixz4AAUOHAlV+emLFf0/iwWLHAgABRwIAIsFixz4AAX9PosFixwFVQX9P4sFixz6qwUOAAbSAAAIqgAACVUAqglVA1UJVQCq";
    // 9.7 font
    string constant LOCAL_FONT_DATA_SJ1 =
        "T1RUTwAJAIAAAwAQQ0ZGIH0Qv40AAARQAAAB6U9TLzJzdHLlAAABAAAAAGBjbWFwALgApgAAA+wAAABEaGVhZDDAoOgAAACcAAAANmhoZWETVQlbAAAA1AAAACRobXR4KtAD/gAABjwAAAAUbWF4cAAFUAAAAAD4AAAABm5hbWX5agBpAAABYAAAAotwb3N0AAMAAAAABDAAAAAgAAEAAAABAAAzsW7zXw889QADCAAAAAAA5IAp+AAAAADkgCn4AAAAAAiqCAAAAAADAAIAAAAAAAAAAQAACAAAAAAACVUAAAAAC1QAAQAAAAAAAAAAAAAAAAAAAAUAAFAAAAUAAAADCJAB9AAFAAACigK7AAAAjAKKArsAAAHfADEBAgAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAABYWFhYAEAAIABTCAAAAAAACAAAAAAAAAEAAAAABAAIAAAgACAAAAAAACIBngABAAAAAAAAAAEAOQABAAAAAAABAAkAAAABAAAAAAACAAcAGwABAAAAAAADABMAtAABAAAAAAAEABEAMAABAAAAAAAFAAsAkwABAAAAAAAGABAAYwABAAAAAAAHAAEAOQABAAAAAAAIAAEAOQABAAAAAAAJAAEAOQABAAAAAAAKAAEAOQABAAAAAAALAAEAOQABAAAAAAAMAAEAOQABAAAAAAANAAEAOQABAAAAAAAOAAEAOQABAAAAAAAQAAkAAAABAAAAAAARAAcAGwADAAEECQAAAAIAUwADAAEECQABABIACQADAAEECQACAA4AIgADAAEECQADACYAxwADAAEECQAEACIAQQADAAEECQAFABYAngADAAEECQAGACAAcwADAAEECQAHAAIAUwADAAEECQAIAAIAUwADAAEECQAJAAIAUwADAAEECQAKAAIAUwADAAEECQALAAIAUwADAAEECQAMAAIAUwADAAEECQANAAIAUwADAAEECQAOAAIAUwADAAEECQAQABIACQADAAEECQARAA4AImJyYWlsbGUyMwBiAHIAYQBpAGwAbABlADIAM1JlZ3VsYXIAUgBlAGcAdQBsAGEAcmJyYWlsbGUyMyBSZWd1bGFyAGIAcgBhAGkAbABsAGUAMgAzACAAUgBlAGcAdQBsAGEAcmJyYWlsbGUyM1JlZ3VsYXIAYgByAGEAaQBsAGwAZQAyADMAUgBlAGcAdQBsAGEAclZlcnNpb24gMC4xAFYAZQByAHMAaQBvAG4AIAAwAC4AMSA6YnJhaWxsZTIzIFJlZ3VsYXIAIAA6AGIAcgBhAGkAbABsAGUAMgAzACAAUgBlAGcAdQBsAGEAcgAAAAABAAMAAQAAAAwABAA4AAAACgAIAAIAAgAgADEASgBT//8AAAAgADEASgBT////4f/R/7n/sQABAAAAAAAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAEAQABAQERYnJhaWxsZTIzUmVndWxhcgABAQFD+BsA+BwC+B0D+B4Ei4scCAAcCVUFHQAAAJcPHQAAAKARix0AAAHpEh4KAASIKBJfHg8eDx4KAASIKBJfHg8eDwwHAAUBAQwdJi0tVmVyc2lvbiAwLjFicmFpbGxlMjMgUmVndWxhcmJyYWlsbGUyM1JlZ3VsYXIAAAABiwGLAYsBiwAFAgABAG4AcgCNAM8BOxwG0tC9FRwFnYsF/WP6TgX9Yv5OBXgcB4gVixz4iwX5YvpPBf1i+k4F+Yj+ThX5Y/5PBYscB3UF/WP+TgX9dfpiFfli/k8F+WP6TwUc+mOLBRwF4hz4MhUc+dmLBYscCAAFHAYniwWLHPgABQ4cCKoOHAiqHAVVixX9P4sFixwFVQX5P4sFixz6qwUOHAlV+emLFf0/iwWL+T4F+T+LBYv9PgX5P/k+Ff0/iwWL+T8F+T+LBYv9PwX5Pvk/Ff0+iwWL+T8F+T6LBYv9PwUOHAlV+emLFf0/iwWL+T4F+T+LBYv9PgUcBVWLFf0+iwWL+T4F+T6LBYv9PgX9Pvk+Ff0/iwWL+T8F+T+LBYv9PwX9P/k/Ff0/iwWL+T8F+T+LBYv9PwUcBVWLFf0+iwWL+T8F+T6LBYv9PwUOAAAABtIAAAiqAAAIqgKqCVUAqglVAKo=";

    /* ------------------------ mint ----------------------------------- */
    function mint(address to, uint256 id) external {
        _safeMint(to, id);
    }

    function _subset(uint256 tokenId) internal pure returns (uint8) {
        RandomCtx memory ctx = Random.initCtx(tokenId);
        return uint8(Random.randInt(ctx) % 3);
    }

    struct AnimationParams {
        uint32 duration; // 4-12 seconds
        uint32 hBarStart; // horizontal bar start position
        uint32 vBarStart; // vertical bar start position
        uint32 hSweepOffset; // horizontal sweep offset (0-360 degrees of cycle)
        uint32 vSweepOffset; // vertical sweep offset (0-360 degrees of cycle)
        bool hReverse; // reverse horizontal direction
        bool vReverse; // reverse vertical direction
    }

    function _generateAnimationParams(
        uint256 tokenId
    ) internal pure returns (AnimationParams memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId);

        return
            AnimationParams({
                duration: uint32(4 + (Random.randInt(ctx) % 9)), // 4-12 seconds
                hBarStart: uint32(Random.randInt(ctx) % 720),
                vBarStart: uint32(Random.randInt(ctx) % 720),
                // Light follows bar with minimal lag - use same offset for true sync
                hSweepOffset: uint32(Random.randInt(ctx) % 20), // 0-20 degree offset (very tight sync)
                vSweepOffset: uint32(Random.randInt(ctx) % 20), // 0-20 degree offset (very tight sync)
                hReverse: (Random.randInt(ctx) % 2) == 1,
                vReverse: (Random.randInt(ctx) % 2) == 1
            });
    }

    function _neonStrip(
        string memory cls,
        bool vertical,
        uint256 startPos,
        uint256 dur,
        bool reverse,
        bool glow
    ) internal pure returns (string memory) {
        // Build core attributes in parts to avoid stack depth
        string memory rectAttrs = vertical
            ? string.concat(
                'x="',
                Strings.toString(startPos),
                '" y="0" width="10" height="720"'
            )
            : string.concat(
                'y="',
                Strings.toString(startPos),
                '" x="0" width="720" height="10"'
            );

        // Build animation values
        uint256 endPos = (startPos + 640) % 720;
        string memory animValues = reverse
            ? string.concat(
                Strings.toString(endPos),
                ";",
                Strings.toString(startPos),
                ";",
                Strings.toString(endPos)
            )
            : string.concat(
                Strings.toString(startPos),
                ";",
                Strings.toString(endPos),
                ";",
                Strings.toString(startPos)
            );

        // Build opening tag
        string memory openTag = string.concat(
            '<rect class="',
            cls,
            '" ',
            rectAttrs,
            glow ? ' filter="url(#blur)">' : ">"
        );

        // Build animation
        string memory animation = string.concat(
            '<animate attributeName="',
            vertical ? "x" : "y",
            '" values="',
            animValues,
            '" dur="',
            Strings.toString(dur),
            's" repeatCount="indefinite"/></rect>'
        );

        return string.concat(openTag, animation);
    }

    function _neonBar(
        string memory cls,
        bool vertical,
        uint256 startPos,
        uint256 dur,
        bool reverse
    ) internal pure returns (string memory) {
        return
            string.concat(
                _neonStrip(cls, vertical, startPos, dur, reverse, true), // blurred glow
                _neonStrip(cls, vertical, startPos, dur, reverse, false) // crisp core
            );
    }

    function _createGradient(
        bool isVertical,
        string memory color,
        uint32 offset,
        bool reverse,
        string memory dur
    ) internal pure returns (string memory) {
        // Pre-calculate all values to minimize stack usage
        string memory gradId = isVertical ? "cgY" : "cgX";
        string memory coords = isVertical ? 'x2="0" y2="1"' : 'x2="1" y2="0"';
        string memory attr1 = isVertical ? "y1" : "x1";
        string memory attr2 = isVertical ? "y2" : "x2";

        return
            string.concat(
                _gradientHeader(gradId, coords),
                _gradientStops(color),
                _gradientAnimations(attr1, attr2, offset, reverse, dur)
            );
    }

    function _gradientHeader(
        string memory gradId,
        string memory coords
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<linearGradient id="',
                gradId,
                '" x1="0" y1="0" ',
                coords,
                ">"
            );
    }

    function _gradientStops(
        string memory color
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<stop offset="0%" stop-color="#111"/>',
                '<stop offset="45%" stop-color="',
                color,
                '"/>',
                '<stop offset="55%" stop-color="#fff"/>',
                '<stop offset="65%" stop-color="',
                color,
                '"/>',
                '<stop offset="100%" stop-color="#111"/>'
            );
    }

    function _gradientAnimations(
        string memory attr1,
        string memory attr2,
        uint32 offset,
        bool reverse,
        string memory dur
    ) internal pure returns (string memory) {
        string memory offsetPct = Strings.toString((offset * 100) / 360);

        // Light sweeps follow the bar position - when bar is at 0, light is at 0
        // When bar is at far end, light sweeps to far end
        string memory values1 = reverse ? "1;-0.5;1" : "-0.5;1;-0.5";
        string memory values2 = reverse ? "1.5;0.5;1.5" : "0.5;1.5;0.5";

        return
            string.concat(
                '<animate attributeName="',
                attr1,
                '" values="',
                values1,
                '" keyTimes="0;.',
                offsetPct,
                ';1" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                '<animate attributeName="',
                attr2,
                '" values="',
                values2,
                '" keyTimes="0;.',
                offsetPct,
                ';1" dur="',
                dur,
                's" repeatCount="indefinite"/>',
                "</linearGradient>"
            );
    }

    function _chromeGrads(
        AnimationParams memory params,
        string memory hColor,
        string memory vColor
    ) internal pure returns (string memory) {
        string memory dur = Strings.toString(params.duration);

        return
            string.concat(
                "<defs>",
                // Horizontal bar creates vertical sweep (perpendicular lighting)
                _createGradient(
                    true,
                    vColor,
                    params.hSweepOffset,
                    params.hReverse,
                    dur
                ),
                // Vertical bar creates horizontal sweep (perpendicular lighting)
                _createGradient(
                    false,
                    hColor,
                    params.vSweepOffset,
                    params.vReverse,
                    dur
                ),
                "</defs>"
            );
    }

    function _svg(uint256 id) internal view returns (string memory) {
        return _buildSVGFromId(id);
    }

    // First function - handles decompression and font selection
    function _buildSVGFromId(uint256 id) internal view returns (string memory) {
        uint8 subset = _subset(id);

        // Decompress tspans
        Blob memory b = blobs[subset];
        bytes memory cd = SSTORE2.read(b.ptr);
        bytes memory ts = InflateLib.puff(cd, b.rawLen);

        // Select font and size
        string memory font = subset == 0 ? LOCAL_FONT_DATA_GHZ : subset == 1
            ? LOCAL_FONT_DATA_RGH
            : LOCAL_FONT_DATA_SJ1;
        string memory fs = subset == 0 ? "9.2" : subset == 1 ? "8.75" : "8.7";

        return _buildSVGWithParams(id, ts, font, fs);
    }

    // Second function - handles animation params and colors
    function _buildSVGWithParams(
        uint256 id,
        bytes memory ts,
        string memory font,
        string memory fs
    ) internal pure returns (string memory) {
        AnimationParams memory params = _generateAnimationParams(id);
        (string memory A, string memory B, string memory C) = _palette(id);

        return _assembleFinalSVG(id, ts, font, fs, params, A, B, C);
    }

    // Third function - assembles the final SVG (reduced parameters)
    function _assembleFinalSVG(
        uint256 id,
        bytes memory ts,
        string memory font,
        string memory fs,
        AnimationParams memory params,
        string memory A,
        string memory B,
        string memory C
    ) internal pure returns (string memory) {
        return
            string.concat(
                _buildSVGHeader(id, font, A, B, C, params),
                _buildSVGBody(id, ts, fs, params),
                "</svg>"
            );
    }

    // Build the SVG header section
    function _buildSVGHeader(
        uint256 id,
        string memory font,
        string memory A,
        string memory B,
        string memory C,
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<svg viewBox="0 0 720 720" xmlns="http://www.w3.org/2000/svg">',
                _createStyles(A, B, C, font, id),
                _createFilters(),
                _createMetals(),
                _chromeGrads(params, B, A),
                '<rect width="720" height="720" fill="#000"/>'
            );
    }

    // Build the SVG body section
    function _buildSVGBody(
        uint256 id,
        bytes memory ts,
        string memory fs,
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string.concat(
                _buildNeonBars(params),
                _buildAnimatedText(id, ts, fs)
            );
    }

    // Build neon bars
    function _buildNeonBars(
        AnimationParams memory params
    ) internal pure returns (string memory) {
        return
            string.concat(
                _neonBar(
                    "a",
                    false,
                    params.hBarStart,
                    params.duration,
                    params.hReverse
                ),
                _neonBar(
                    "b",
                    true,
                    params.vBarStart,
                    params.duration,
                    params.vReverse
                )
            );
    }

    // // Build animated text
    // function _buildAnimatedText(
    //     uint256 id,
    //     bytes memory ts,
    //     string memory fs
    // ) internal pure returns (string memory) {
    //     return
    //         string.concat(
    //             "<g>",
    //             id % 2 == 0
    //                 ? '<animateTransform attributeName="transform" type="translate" values="0,0;15,0;0,0;-15,0;0,0" dur="6s" repeatCount="indefinite"/>'
    //                 : '<animateTransform attributeName="transform" type="translate" values="0,0;-15,0;0,0;15,0;0,0" dur="6s" repeatCount="indefinite"/>',
    //             _chromeTextWithWave(ts, fs, false, id),
    //             "</g>"
    //         );
    // }

    function _buildAnimatedText(
        uint256 id,
        bytes memory ts,
        string memory fs
    ) internal pure returns (string memory) {
        return _chromeTextWithWave(ts, fs, false, id); // No parent <g> with animation
    }

    function _textWithAnimation(
        bytes memory tspans,
        string memory fontSize,
        uint256 tokenId
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<g>",
                tokenId % 2 == 0
                    ? '<animateTransform attributeName="transform" type="translate" values="0,0;15,0;0,0;-15,0;0,0" dur="6s" repeatCount="indefinite"/>'
                    : '<animateTransform attributeName="transform" type="translate" values="0,0;-15,0;0,0;15,0;0,0" dur="6s" repeatCount="indefinite"/>',
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgX)">',
                string(tspans),
                "</text>",
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgY)" opacity=".45">',
                string(tspans),
                "</text>",
                "</g>"
            );
    }

    /* ---------- glowing filter ------------------------------------ */
    function _createFilters() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    // open <defs>
                    "<defs>",
                    // big absolute filter box (−720 .. +1440 in both axes)
                    '<filter id="blur" filterUnits="userSpaceOnUse" ',
                    'x="-720" y="-720" width="2160" height="2160">',
                    // first blur to soften the strip
                    '<feGaussianBlur in="SourceGraphic" stdDeviation="20" result="soft"/>',
                    // brighten (×6 on each RGB channel)
                    '<feColorMatrix in="soft" type="matrix" values="'
                    "3 0 0 0 0 "
                    "0 3 0 0 0 "
                    "0 0 3 0 0 "
                    '0 0 0 0.7 0" result="bright"/>',
                    // huge outer halo
                    '<feGaussianBlur in="bright" stdDeviation="50" result="glow"/>',
                    // merge glow + bright core
                    "<feMerge>",
                    '<feMergeNode in="glow"/>',
                    '<feMergeNode in="bright"/>',
                    "</feMerge>",
                    "</filter>",
                    "</defs>"
                )
            );
    }

    function _chromeText(
        bytes memory tspans,
        string memory fontSize,
        bool addGlow
    ) internal pure returns (string memory) {
        string memory txt = string(tspans); // one cast, reuse twice

        return
            string.concat(
                /* base – horizontal sweep */
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central"',
                (addGlow ? ' filter="url(#spec)"' : ""),
                ' fill="url(#cgX)">',
                txt,
                "</text>",
                /* overlay – vertical sweep, 45 % α */
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgY)" opacity=".45">',
                txt,
                "</text>"
            );
    }

    // function _chromeTextWithWave(
    //     bytes memory tspans,
    //     string memory fontSize,
    //     bool addGlow,
    //     uint256 tokenId
    // ) internal pure returns (string memory) {
    //     string memory txt = _assignWaveClasses(tspans, tokenId);

    //     return
    //         string.concat(
    //             // Base layer - horizontal sweep
    //             '<text x="0" y="0" class="g f" font-size="',
    //             fontSize,
    //             '" text-anchor="start" dominant-baseline="central"',
    //             (addGlow ? ' filter="url(#spec)"' : ""),
    //             ' fill="url(#cgX)">',
    //             txt,
    //             "</text>",
    //             // Overlay layer - vertical sweep, 45% opacity
    //             '<text x="0" y="0" class="g f" font-size="',
    //             fontSize,
    //             '" text-anchor="start" dominant-baseline="central" fill="url(#cgY)" opacity=".45">',
    //             txt,
    //             "</text>"
    //         );
    // }

    function _chromeTextWithWave(
        bytes memory tspans,
        string memory fontSize,
        bool addGlow,
        uint256 tokenId
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgX)">',
                _assignWaveClasses(tspans, tokenId),
                "</text>",
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgY)" opacity=".45">',
                _assignWaveClasses(tspans, tokenId),
                "</text>"
            );
    }

    function _chromeTextAnimated(
        bytes memory tspans,
        string memory fontSize,
        bool addGlow,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory txt = string(tspans);

        // Generate animation directly here with minimal variables
        string memory anim = tokenId % 2 == 0
            ? '<animateTransform attributeName="transform" type="translate" values="0,0;15,0;0,0;-15,0;0,0" dur="6s" repeatCount="indefinite"/>'
            : '<animateTransform attributeName="transform" type="translate" values="0,0;-15,0;0,0;15,0;0,0" dur="6s" repeatCount="indefinite"/>';

        return
            string.concat(
                "<g>",
                anim,
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgX)">',
                txt,
                "</text>",
                '<text x="0" y="0" class="g f" font-size="',
                fontSize,
                '" text-anchor="start" dominant-baseline="central" fill="url(#cgY)" opacity=".45">',
                txt,
                "</text>",
                "</g>"
            );
    }

    /* ---------- metallic defs ----CURRENTLY UNUSED--------------------------------- */
    function _createMetals() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<defs>",
                    /* ---------- updated specular filter (drop-in) ------------------ */
                    '<filter id="spec" x="-20%" y="-20%" width="140%" height="140%">',
                    /* small blur of alpha to catch edges */
                    '<feGaussianBlur in="SourceAlpha" stdDeviation="2" result="b"/>',
                    /* milder specular highlight */
                    '<feSpecularLighting in="b" surfaceScale="1" specularConstant=".4" ',
                    'specularExponent="15" lighting-color="#ffffff" result="s">',
                    '<fePointLight x="-2000" y="-2000" z="8000"/>',
                    "</feSpecularLighting>",
                    /* isolate highlight to glyph shape */
                    '<feComposite in="s" in2="SourceAlpha" operator="in" result="h"/>',
                    /* blend highlight on top with 40 % screen */
                    '<feBlend in="SourceGraphic" in2="h" mode="screen" result="final" />',
                    '<feComponentTransfer in="final"><feFuncA type="linear" slope=".4"/></feComponentTransfer>',
                    "</filter>",
                    "</defs>"
                )
            );
    }

    // Create style definitions
    /* ---------- style builder (+ optional flicker) -------------------- */
    // function _createStyles(
    //     string memory A,
    //     string memory B,
    //     string memory C,
    //     string memory font
    // ) internal pure returns (string memory) {
    //     /* 1️⃣  colour classes already used by your <tspan>s */
    //     string memory colourRules = string.concat(
    //         "<style>",
    //         ".a{fill:",
    //         A,
    //         "}",
    //         ".b{fill:",
    //         B,
    //         "}",
    //         ".c{fill:",
    //         C,
    //         "}"
    //     );

    //     /* 2️⃣  global key-frame that imitates a tube-light “blink”
    //         0% / 63 % / 100 % → fully lit
    //         10 % / 60 %      → half lit             */
    //     string memory flickerCSS = "@keyframes flick{0%,20%,63%,100%{opacity:1}"
    //     "10%,60%{opacity:.35}}"
    //     ".f{animation:flick .18s infinite}";

    //     /* 3️⃣  optional @font-face (kept exactly as you had it) */
    //     string memory fontCSS = bytes(font).length != 0
    //         ? string.concat(
    //             "@font-face{font-family:AsciiArtFont;src:url(data:font/ttf;base64,",
    //             font,
    //             ') format("truetype");}',
    //             ".g{font-family:AsciiArtFont;}"
    //         )
    //         : "";

    //     return string.concat(colourRules, flickerCSS, fontCSS, "</style>");
    // }

    function _createStyles(
        string memory A,
        string memory B,
        string memory C,
        string memory font,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory colourRules = string.concat(
            "<style>",
            ".a{fill:",
            A,
            "}",
            ".b{fill:",
            B,
            "}",
            ".c{fill:",
            C,
            "}"
        );

        string memory flickerCSS = "@keyframes flick{0%,20%,63%,100%{opacity:1}"
        "10%,60%{opacity:.35}}"
        ".f{animation:flick .18s infinite}";

        string memory waveCSS = _getWavePattern(tokenId);

        string memory fontCSS = bytes(font).length != 0
            ? string.concat(
                "@font-face{font-family:AsciiArtFont;src:url(data:font/ttf;base64,",
                font,
                ') format("truetype");}',
                ".g{font-family:AsciiArtFont;}"
            )
            : "";

        return
            string.concat(
                colourRules,
                flickerCSS,
                waveCSS,
                fontCSS,
                "</style>"
            );
    }

    // function _getWavePattern(
    //     uint256 tokenId
    // ) internal pure returns (string memory) {
    //     uint256 pattern = tokenId % 3;
    //     if (pattern == 0)
    //         return
    //             "@keyframes wave{0%,100%{transform:translateX(0)}50%{transform:translateX(15px)}} .wave{animation:wave 5s ease-in-out infinite}";
    //     if (pattern == 1)
    //         return
    //             "@keyframes wave{0%,100%{transform:translateX(0)}33%{transform:translateX(-20px)}66%{transform:translateX(20px)}} .wave{animation:wave 7s ease-in-out infinite}";
    //     return
    //         "@keyframes wave{0%,100%{transform:translateX(0)}25%{transform:translateX(10px)}75%{transform:translateX(-10px)}} .wave{animation:wave 4s ease-in-out infinite}";
    // }

    // function _assignWaveClasses(
    //     bytes memory tspans,
    //     uint256 tokenId
    // ) internal pure returns (string memory) {
    //     string memory tspanStr = string(tspans);

    //     // Determine which wave classes to use based on tokenId
    //     string memory topWave = tokenId % 3 == 0 ? "wave1" : tokenId % 3 == 1
    //         ? "wave2"
    //         : "wave3";
    //     string memory midWave = tokenId % 3 == 0 ? "wave2" : tokenId % 3 == 1
    //         ? "wave3"
    //         : "wave1";
    //     string memory botWave = tokenId % 3 == 0 ? "wave3" : tokenId % 3 == 1
    //         ? "wave1"
    //         : "wave2";

    //     return _parseAndAssignWaves(tspanStr, topWave, midWave, botWave);
    // }

    function _parseAndAssignWaves(
        string memory tspans,
        string memory topWave,
        string memory midWave,
        string memory botWave
    ) internal pure returns (string memory) {
        bytes memory data = bytes(tspans);
        bytes memory result = new bytes(data.length * 3); // Allocate extra space for class additions
        uint256 resultIndex = 0;
        uint256 i = 0;

        while (i < data.length) {
            if (
                i < data.length - 6 &&
                data[i] == "<" &&
                data[i + 1] == "t" &&
                data[i + 2] == "s" &&
                data[i + 3] == "p" &&
                data[i + 4] == "a" &&
                data[i + 5] == "n"
            ) {
                // Found a tspan - extract y coordinate and add appropriate wave class
                (uint256 yCoord, uint256 skipLength) = _extractYCoordinate(
                    data,
                    i
                );
                string memory waveClass = _getWaveClassForY(
                    yCoord,
                    topWave,
                    midWave,
                    botWave
                );

                // Copy the tspan opening with added wave class
                (
                    bytes memory modifiedTspan,
                    uint256 tspanLength
                ) = _addWaveClassToTspan(data, i, waveClass);

                // Copy modified tspan to result
                for (uint256 j = 0; j < modifiedTspan.length; j++) {
                    result[resultIndex++] = modifiedTspan[j];
                }

                i += tspanLength;
            } else {
                result[resultIndex++] = data[i];
                i++;
            }
        }

        // Resize result to actual length
        bytes memory finalResult = new bytes(resultIndex);
        for (uint256 k = 0; k < resultIndex; k++) {
            finalResult[k] = result[k];
        }

        return string(finalResult);
    }

    function _extractYCoordinate(
        bytes memory data,
        uint256 startIndex
    ) internal pure returns (uint256 yCoord, uint256 skipLength) {
        // Look for y="XXX" pattern
        uint256 i = startIndex;
        while (i < data.length - 3) {
            if (data[i] == "y" && data[i + 1] == "=" && data[i + 2] == '"') {
                i += 3; // Skip y="
                uint256 numStart = i;

                // Extract the number
                while (i < data.length && data[i] != '"') {
                    i++;
                }

                // Convert bytes to number
                yCoord = _bytesToUint(data, numStart, i - numStart);

                // Find the end of this tspan
                while (
                    i < data.length &&
                    !(data[i] == ">" && (i == 0 || data[i - 1] != "/"))
                ) {
                    i++;
                }
                skipLength = i - startIndex + 1;
                return (yCoord, skipLength);
            }
            i++;
        }

        return (360, 10); // Default middle position if parsing fails
    }

    function _bytesToUint(
        bytes memory data,
        uint256 start,
        uint256 length
    ) internal pure returns (uint256 result) {
        for (uint256 i = 0; i < length; i++) {
            uint8 digit = uint8(data[start + i]);
            if (digit >= 48 && digit <= 57) {
                // '0' to '9'
                result = result * 10 + (digit - 48);
            }
        }
    }

    function _getWaveClassForY(
        uint256 yCoord,
        string memory topWave,
        string memory midWave,
        string memory botWave
    ) internal pure returns (string memory) {
        // Assuming 720px canvas height, divide into thirds
        if (yCoord < 240) return topWave; // Top third
        if (yCoord < 480) return midWave; // Middle third
        return botWave; // Bottom third
    }

    function _addWaveClassToTspan(
        bytes memory data,
        uint256 startIndex,
        string memory waveClass
    )
        internal
        pure
        returns (bytes memory modifiedTspan, uint256 originalLength)
    {
        // Find the end of the opening tspan tag
        uint256 i = startIndex;
        while (i < data.length && data[i] != ">") {
            i++;
        }

        originalLength = i - startIndex + 1;

        // Look for existing class attribute or add new one
        bool hasClass = false;
        uint256 classPos = 0;

        for (uint256 j = startIndex; j < i - 6; j++) {
            if (
                data[j] == "c" &&
                data[j + 1] == "l" &&
                data[j + 2] == "a" &&
                data[j + 3] == "s" &&
                data[j + 4] == "s" &&
                data[j + 5] == "="
            ) {
                hasClass = true;
                classPos = j + 7; // Position after class="
                break;
            }
        }

        bytes memory waveBytes = bytes(waveClass);

        if (hasClass) {
            // Insert wave class into existing class attribute
            modifiedTspan = new bytes(originalLength + waveBytes.length + 1);
            uint256 idx = 0;

            // Copy up to class position
            for (
                uint256 k = startIndex;
                k < startIndex + classPos - startIndex;
                k++
            ) {
                modifiedTspan[idx++] = data[k];
            }

            // Add wave class
            for (uint256 k = 0; k < waveBytes.length; k++) {
                modifiedTspan[idx++] = waveBytes[k];
            }
            modifiedTspan[idx++] = " ";

            // Copy rest
            for (
                uint256 k = startIndex + classPos - startIndex;
                k < startIndex + originalLength;
                k++
            ) {
                modifiedTspan[idx++] = data[k];
            }
        } else {
            // Add new class attribute before closing >
            modifiedTspan = new bytes(originalLength + waveBytes.length + 10);
            uint256 idx = 0;

            // Copy up to closing >
            for (uint256 k = startIndex; k < i; k++) {
                modifiedTspan[idx++] = data[k];
            }

            // Add class attribute
            bytes memory classAttr = bytes(
                string.concat(' class="', waveClass, '"')
            );
            for (uint256 k = 0; k < classAttr.length; k++) {
                modifiedTspan[idx++] = classAttr[k];
            }

            // Add closing >
            modifiedTspan[idx++] = ">";
        }
    }

    // * NEW WAVE APPROACH */

    function _assignWaveClasses(
        bytes memory tspans,
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory tspanStr = string(tspans);
        return _addPositionalWaveClasses(tspanStr, tokenId);
    }

    function _addPositionalWaveClasses(
        string memory tspans,
        uint256 tokenId
    ) internal pure returns (string memory) {
        bytes memory data = bytes(tspans);
        bytes memory result = new bytes(data.length * 2); // Extra space for classes
        uint256 resultIndex = 0;
        uint256 tspanCount = 0;
        uint256 i = 0;

        while (i < data.length) {
            if (
                i < data.length - 6 &&
                data[i] == "<" &&
                data[i + 1] == "t" &&
                data[i + 2] == "s" &&
                data[i + 3] == "p" &&
                data[i + 4] == "a" &&
                data[i + 5] == "n"
            ) {
                // Found a tspan - determine wave class based on position
                string memory waveClass = _getWaveClassForPosition(
                    tspanCount,
                    tokenId
                );

                // Copy "<tspan"
                for (uint256 j = 0; j < 6; j++) {
                    result[resultIndex++] = data[i + j];
                }
                i += 6;

                // Add class attribute right after <tspan
                bytes memory classAttr = bytes(
                    string.concat(' class="', waveClass, '"')
                );
                for (uint256 k = 0; k < classAttr.length; k++) {
                    result[resultIndex++] = classAttr[k];
                }

                tspanCount++;
            } else {
                result[resultIndex++] = data[i];
                i++;
            }
        }

        // Resize result to actual length
        bytes memory finalResult = new bytes(resultIndex);
        for (uint256 k = 0; k < resultIndex; k++) {
            finalResult[k] = result[k];
        }

        return string(finalResult);
    }

    function _getWaveClassForPosition(
        uint256 position,
        uint256 tokenId
    ) internal pure returns (string memory) {
        // Create different wave patterns based on position in the sequence
        uint256 pattern = (position + tokenId) % 9; // 9 different patterns

        if (pattern == 0) return "wave1";
        if (pattern == 1) return "wave2";
        if (pattern == 2) return "wave3";
        if (pattern == 3) return "wave1 delay1";
        if (pattern == 4) return "wave2 delay1";
        if (pattern == 5) return "wave3 delay1";
        if (pattern == 6) return "wave1 delay2";
        if (pattern == 7) return "wave2 delay2";
        return "wave3 delay2";
    }

    // function _getWavePattern(
    //     uint256 tokenId
    // ) internal pure returns (string memory) {
    //     uint256 pattern = tokenId % 3;

    //     string memory baseWaves;
    //     if (pattern == 0) {
    //         baseWaves = "@keyframes wave1{0%,100%{transform:translateX(0)}50%{transform:translateX(15px)}} .wave1{animation:wave1 5s ease-in-out infinite}";
    //     } else if (pattern == 1) {
    //         baseWaves = "@keyframes wave2{0%,100%{transform:translateX(0)}33%{transform:translateX(-20px)}66%{transform:translateX(20px)}} .wave2{animation:wave2 7s ease-in-out infinite}";
    //     } else {
    //         baseWaves = "@keyframes wave3{0%,100%{transform:translateX(0)}25%{transform:translateX(10px)}75%{transform:translateX(-10px)}} .wave3{animation:wave3 4s ease-in-out infinite}";
    //     }

    //     // Add delay variations
    //     string memory delayWaves = string.concat(
    //         ".delay1{animation-delay:0.5s}",
    //         ".delay2{animation-delay:1s}",
    //         ".wave1.delay1{animation:wave1 5s ease-in-out infinite;animation-delay:0.5s}",
    //         ".wave1.delay2{animation:wave1 5s ease-in-out infinite;animation-delay:1s}",
    //         ".wave2.delay1{animation:wave2 7s ease-in-out infinite;animation-delay:0.5s}",
    //         ".wave2.delay2{animation:wave2 7s ease-in-out infinite;animation-delay:1s}",
    //         ".wave3.delay1{animation:wave3 4s ease-in-out infinite;animation-delay:0.5s}",
    //         ".wave3.delay2{animation:wave3 4s ease-in-out infinite;animation-delay:1s}"
    //     );

    //     return string.concat(baseWaves, delayWaves);
    // }

    function _getWavePattern(
        uint256 tokenId
    ) internal pure returns (string memory) {
        uint256 pattern = tokenId % 3;

        // Make selectors more specific to override existing styles
        string memory baseWaves;
        if (pattern == 0) {
            baseWaves = "@keyframes wave1{0%,100%{transform:translateX(0px)!important}50%{transform:translateX(15px)!important}} tspan.wave1{animation:wave1 5s ease-in-out infinite!important}";
        } else if (pattern == 1) {
            baseWaves = "@keyframes wave2{0%,100%{transform:translateX(0px)!important}33%{transform:translateX(-20px)!important}66%{transform:translateX(20px)!important}} tspan.wave2{animation:wave2 7s ease-in-out infinite!important}";
        } else {
            baseWaves = "@keyframes wave3{0%,100%{transform:translateX(0px)!important}25%{transform:translateX(10px)!important}75%{transform:translateX(-10px)!important}} tspan.wave3{animation:wave3 4s ease-in-out infinite!important}";
        }

        // Add delay variations with higher specificity
        string memory delayWaves = string.concat(
            "tspan.wave1.delay1{animation:wave1 5s ease-in-out infinite!important;animation-delay:0.5s!important}",
            "tspan.wave1.delay2{animation:wave1 5s ease-in-out infinite!important;animation-delay:1s!important}",
            "tspan.wave2.delay1{animation:wave2 7s ease-in-out infinite!important;animation-delay:0.5s!important}",
            "tspan.wave2.delay2{animation:wave2 7s ease-in-out infinite!important;animation-delay:1s!important}",
            "tspan.wave3.delay1{animation:wave3 4s ease-in-out infinite!important;animation-delay:0.5s!important}",
            "tspan.wave3.delay2{animation:wave3 4s ease-in-out infinite!important;animation-delay:1s!important}"
        );

        return string.concat(baseWaves, delayWaves);
    }

    /* ===== colour picker ===== */
    function _pickColour(
        uint256 s,
        string memory A,
        string memory B,
        string memory C
    ) internal pure returns (string memory) {
        uint256 i = (s >> 160) % 3;
        return i == 0 ? A : i == 1 ? B : C;
    }

    /* ===== palette ===== */
    function _palette(
        uint256 tokenId
    ) internal pure returns (string memory, string memory, string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId);
        uint256 i = Random.randInt(ctx) % 6;
        if (i == 0) return ("#FFFF00", "#FF00FF", "#FFFF00");
        if (i == 1) return ("#FF0000", "#FFFF00", "#00FF00");
        if (i == 2) return ("#FF0000", "#00FFFF", "#FFFF00");
        if (i == 3) return ("#FF0000", "#00FFFF", "#00FF00");
        if (i == 4) return ("#00FFFF", "#FF00FF", "#FFFF00");
        return ("#00FFFF", "#FFFF00", "#00FF00");
    }

    /* main hook used by AbstractTest */
    function renderSVG(uint256 id) external view returns (string memory) {
        return _svg(id);
    }

    /*-----metadata hook-----*/
    function tokenURI(uint256 id) public view override returns (string memory) {
        string memory img = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(_svg(id)))
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"NAME #',
                                Strings.toString(id),
                                '","image":"',
                                img,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
