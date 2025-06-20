// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Vm} from "forge-std/Vm.sol";

interface IFileStore {
    function getFile(string memory filename) external view returns (IFile);

    function fileExists(string memory filename) external view returns (bool);
}

interface IFile {
    function read() external view returns (string memory);
}

/**
 * @author Ella Whit
 * @title GRIDSEARCH
 * @notice Uses subsets from my custom font GEOM stored on ETHFS
 */
contract BasicGHZRenderer {
    IFileStore constant fileStore =
        IFileStore(0x9746fD0A77829E12F8A9DBe70D7a322412325B91);
    Vm constant vm =
        Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    string constant LOCAL_FONT_DATA =
        "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";

    function getFontData() internal view returns (string memory) {
        // First try local embedded font data
        if (bytes(LOCAL_FONT_DATA).length > 0) {
            return LOCAL_FONT_DATA;
        }

        // Try to get font from ETHFS
        try this.tryGetFontFromETHFS() returns (string memory fontData) {
            return fontData;
        } catch {
            // Return empty string if both fail
            return "";
        }
    }

    function tryGetFontFromETHFS() external view returns (string memory) {
        string memory fontFileName = "ghz.txt.txt";

        if (fileStore.fileExists(fontFileName)) {
            IFile fontFile = fileStore.getFile(fontFileName);
            return fontFile.read();
        }

        return "";
    }

    // Helper function to test if font file exists locally
    function localFontExists() external pure returns (bool) {
        return bytes(LOCAL_FONT_DATA).length > 0;
    }

    // Helper function to test if font file exists on ETHFS
    function ethfsFontExists() external view returns (bool) {
        try this.tryGetFontFromETHFS() returns (string memory fontData) {
            return bytes(fontData).length > 0;
        } catch {
            return false;
        }
    }

    // Helper function to get font data for debugging
    function getFontDataForTesting() external view returns (string memory) {
        return getFontData();
    }

    // Get info about font source for debugging
    function getFontSource() external view returns (string memory) {
        if (bytes(LOCAL_FONT_DATA).length > 0) {
            return
                string.concat(
                    "LOCAL_EMBEDDED_",
                    toString(bytes(LOCAL_FONT_DATA).length),
                    "_chars"
                );
        }

        try this.tryGetFontFromETHFS() returns (string memory ethfsFont) {
            if (bytes(ethfsFont).length > 0) {
                return
                    string.concat(
                        "ETHFS_",
                        toString(bytes(ethfsFont).length),
                        "_chars"
                    );
            }
        } catch {
            // Continue
        }

        return "FALLBACK_SERIF";
    }

    // Get the first 100 characters of the font data for debugging
    function getFontPreview() external view returns (string memory) {
        string memory fontData = getFontData();
        bytes memory fontBytes = bytes(fontData);

        if (fontBytes.length == 0) {
            return "NO_FONT_DATA";
        }

        uint256 previewLength = fontBytes.length > 100 ? 100 : fontBytes.length;
        bytes memory preview = new bytes(previewLength);

        for (uint256 i = 0; i < previewLength; i++) {
            preview[i] = fontBytes[i];
        }

        return string(preview);
    }

    // Simple version without font (fallback)
    function renderSVGWithoutFont() external pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500">',
                '<rect width="500" height="500" fill="black"/>',
                '<text font-family="serif" font-size="20" x="250" y="250" fill="white" text-anchor="middle">GHZ</text>',
                "</svg>"
            );
    }

    /* ============================================================= */
    /*      PLAIN BLACK BACKGROUND  ·  12×12 GRID  ·  CLIP MASK       */
    /* ============================================================= */

    function renderSVG(uint256 tokenId) public view returns (string memory) {
        return _build(tokenId, getFontData());
    }

    /* ===== core builder (≤9 locals) ===== */
    function _build(
        uint256 id,
        string memory font
    ) internal pure returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(id)));
        (string memory A, string memory B, string memory C) = _palette(seed);

        // two shapes with inline colour pick
        string memory s1 = _shape(seed, _pickColour(seed, A, B, C));
        string memory s2 = _shape(seed >> 1, _pickColour(seed >> 1, A, B, C));

        // letter groups
        (string memory col, string memory plain) = _letters(seed, A, B, C);

        // defs (clips, grain, style)
        string memory defs = _defs(s1, s2, seed, font);

        /* --- assemble SVG --- */
        return
            string.concat(
                '<svg viewBox="0 0 480 480"><rect width="480" height="480" fill="#000"/>',
                defs,
                s1,
                s2,
                '<g filter="url(#g)">',
                // coloured everywhere first
                '<g font-family="g" font-size="32">',
                col,
                "</g>",
                // black inside shape‑1 only
                '<g clip-path="url(#s1only)" fill="#000" font-family="g" font-size="32">',
                plain,
                "</g>",
                // black inside shape‑2 only
                '<g clip-path="url(#s2only)" fill="#000" font-family="g" font-size="32">',
                plain,
                "</g>",
                "</g></svg>"
            );
    }

    /* ===== defs helper ===== */
    function _defs(
        string memory s1,
        string memory s2,
        uint256 seed,
        string memory font
    ) internal pure returns (string memory) {
        (string memory A, string memory B, string memory C) = _palette(seed);
        return
            string.concat(
                "<defs>",
                // subtle grain filter
                '<filter id="g"><feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="1" result="n"/><feColorMatrix type="saturate" values="0"/><feComponentTransfer><feFuncA type="linear" slope="0.12"/></feComponentTransfer><feBlend in="SourceGraphic" in2="n" mode="multiply"/></filter>',
                // base shape clips
                '<clipPath id="s1">',
                s1,
                "</clipPath>",
                '<clipPath id="s2">',
                s2,
                "</clipPath>",
                // s1 only = s1 minus s2 (evenodd order matters)
                '<clipPath id="s1only" clip-rule="evenodd">',
                s1,
                s2,
                "</clipPath>",
                // s2 only = s2 minus s1
                '<clipPath id="s2only" clip-rule="evenodd">',
                s2,
                s1,
                "</clipPath>",
                // palette + font
                "<style>",
                ".a{fill:",
                A,
                "}.b{fill:",
                B,
                "}.c{fill:",
                C,
                "}",
                bytes(font).length > 0
                    ? string.concat(
                        "@font-face{font-family:g;src:url(data:application/font-woff2;base64,",
                        font,
                        ') format("woff2");}'
                    )
                    : "",
                "</style>",
                "</defs>"
            );
    }

    /* ===== letters ===== */
    function _letters(
        uint256 seed,
        string memory A,
        string memory B,
        string memory C
    ) internal pure returns (string memory col, string memory plain) {
        for (uint256 r; r < 12; r++) {
            for (uint256 c; c < 12; c++) {
                seed = uint256(keccak256(abi.encodePacked(seed, r, c)));
                if (seed % 100 < 30) {
                    string memory x = uint2str(c * 40 + 20);
                    string memory y = uint2str(r * 40 + 20);
                    string memory L = seed % 3 == 0 ? "G" : seed % 3 == 1
                        ? "H"
                        : "Z";
                    string memory cls = (seed >> 8) % 3 == 0
                        ? "a"
                        : (seed >> 8) % 3 == 1
                        ? "b"
                        : "c";
                    col = string.concat(
                        col,
                        "<text class=",
                        cls,
                        " x=",
                        x,
                        " y=",
                        y,
                        ">",
                        L,
                        "</text>"
                    );
                    plain = string.concat(
                        plain,
                        "<text x=",
                        x,
                        " y=",
                        y,
                        ">",
                        L,
                        "</text>"
                    );
                }
            }
        }
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

    /* ===== shape builder ===== */
    function _shape(
        uint256 s,
        string memory fill
    ) internal pure returns (string memory) {
        uint256 rSeed = s >> 96; // for positions
        if ((s & 7) != 0) {
            uint256 r = 120 + (s % 120);
            uint256 cx = 40 + ((rSeed >> 16) % 400);
            uint256 cy = 40 + ((rSeed >> 32) % 400);
            return
                string.concat(
                    "<circle cx=",
                    uint2str(cx),
                    " cy=",
                    uint2str(cy),
                    " r=",
                    uint2str(r),
                    ' fill="',
                    fill,
                    '"/>'
                );
        }
        uint256 sz = 240 + (s % 120);
        uint256 max = 480 - sz;
        uint256 x0 = (rSeed >> 48) % max;
        return
            string.concat(
                "<rect x=",
                uint2str(x0),
                " y=",
                uint2str(x0),
                " width=",
                uint2str(sz),
                " height=",
                uint2str(sz),
                ' fill="',
                fill,
                '"/>'
            );
    }

    // /* -------- core builder -------- */
    // function _build(
    //     uint256 id,
    //     string memory font
    // ) internal pure returns (string memory) {
    //     uint256 seed = uint256(keccak256(abi.encodePacked(id)));
    //     (string memory c0, string memory c1, string memory c2) = _palette(seed);
    //     string[3] memory cols = [c0, c1, c2];

    //     string memory bigShape = _shape(seed, cols);
    //     string memory lettersCol = _letters(seed, cols, true); // coloured
    //     string memory lettersPlain = _letters(seed, cols, false); // no fill

    //     /* SVG header + defs */
    //     string memory head = string.concat(
    //         '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 480">',
    //         '<rect width="480" height="480" fill="black"/>',
    //         '<defs><clipPath id="cut">',
    //         bigShape,
    //         "</clipPath></defs>",
    //         bytes(font).length > 0
    //             ? string.concat(
    //                 "<style>@font-face{font-family:geom;src:url(data:application/font-woff2;base64,",
    //                 font,
    //                 ') format("woff2");}</style>'
    //             )
    //             : ""
    //     );

    //     /* paint order: bg → shape → coloured letters → black-clipped letters */
    //     return
    //         string.concat(
    //             head,
    //             bigShape,
    //             '<g font-family="geom,monospace" font-size="32" text-anchor="middle" dominant-baseline="middle">',
    //             lettersCol,
    //             "</g>",
    //             '<g clip-path="url(#cut)" fill="black" font-family="geom,monospace" font-size="32" text-anchor="middle" dominant-baseline="middle">',
    //             lettersPlain,
    //             "</g>",
    //             "</svg>"
    //         );
    // }

    // /* -------- letters builder (flag: withColour) -------- */
    // function _letters(
    //     uint256 seed,
    //     string[3] memory cols,
    //     bool colour
    // ) internal pure returns (string memory out) {
    //     uint256 cell = 40;
    //     uint256 off = 20; // 12×12 grid
    //     string[3] memory glyph = ["G", "H", "Z"];

    //     for (uint256 r; r < 12; r++) {
    //         for (uint256 c; c < 12; c++) {
    //             seed = uint256(keccak256(abi.encodePacked(seed, r, c)));
    //             if (seed % 100 < 30) {
    //                 uint256 x = c * cell + off;
    //                 uint256 y = r * cell + off;
    //                 uint256 g = seed % 3;
    //                 if (colour) {
    //                     uint256 col = (seed >> 8) % 3;
    //                     out = string.concat(
    //                         out,
    //                         '<text fill="',
    //                         cols[col],
    //                         '" x="',
    //                         uint2str(x),
    //                         '" y="',
    //                         uint2str(y),
    //                         '">',
    //                         glyph[g],
    //                         "</text>"
    //                     );
    //                 } else {
    //                     out = string.concat(
    //                         out,
    //                         '<text x="',
    //                         uint2str(x),
    //                         '" y="',
    //                         uint2str(y),
    //                         '">',
    //                         glyph[g],
    //                         "</text>"
    //                     );
    //                 }
    //             }
    //         }
    //     }
    // }

    // /* -------- big random shape -------- */
    // function _shape(
    //     uint256 s,
    //     string[3] memory cols
    // ) internal pure returns (string memory) {
    //     string memory fill = cols[(s >> 160) % 3];
    //     if (((s >> 8) & 1) == 0) {
    //         uint256 r = 120 + (s % 120);
    //         return
    //             string.concat(
    //                 '<circle cx="240" cy="240" r="',
    //                 uint2str(r),
    //                 '" fill="',
    //                 fill,
    //                 '"/>'
    //             );
    //     } else {
    //         uint256 sz = 240 + (s % 120);
    //         uint256 x = 240 - sz / 2;
    //         return
    //             string.concat(
    //                 '<rect x="',
    //                 uint2str(x),
    //                 '" y="',
    //                 uint2str(x),
    //                 '" width="',
    //                 uint2str(sz),
    //                 '" height="',
    //                 uint2str(sz),
    //                 '" fill="',
    //                 fill,
    //                 '"/>'
    //             );
    //     }
    // }

    /* ===== palette ===== */
    function _palette(
        uint256 s
    ) internal pure returns (string memory, string memory, string memory) {
        uint256 i = (s >> 4) % 3;
        if (i == 0) return ("#f0f", "#0ff", "#ff0");
        if (i == 1) return ("#f00", "#0f0", "#00f");
        return ("#ff0", "#0ff", "#0f0");
    }

    /* ---------- helpers ---------- */
    function uint2str(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 digits;
        uint256 tmp = v;
        while (tmp != 0) {
            digits++;
            tmp /= 10;
        }
        bytes memory buf = new bytes(digits);
        while (v != 0) {
            digits--;
            buf[digits] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        return string(buf);
    }

    function toString(uint256 v) internal pure returns (string memory) {
        return uint2str(v);
    }
}
