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

    /* ---------- external entry ---------- */
    function renderSVG(uint256 tokenId) public view returns (string memory) {
        return _build(tokenId, getFontData());
    }

    /* ===== core builder (≤14 locals) ===== */
    function _build(
        uint256 tokenId,
        string memory font
    ) internal pure returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(tokenId)));
        uint256 B = 6 + 2 * (seed & 3); // 6,8,10,12
        uint256 mirror = 1 + ((seed >> 2) % 3); // 1=X, 2=Y, 3=Both
        uint256 cell = 480 / (2 * B); // 40,30,24,20 (always int)
        uint256 fontPx = (cell * 9) / 10;

        string memory svgHead = _header(font, fontPx, seed, cell);

        /* ---- inner scope (max 8 locals) ---- */
        {
            uint256 bw = (mirror == 2 || mirror == 3) ? B : 2 * B; // columns count
            uint256 bh = (mirror == 1 || mirror == 3) ? B : 2 * B; // rows count
            bw *= cell; // px width of base
            bh *= cell; // px height of base

            string memory content = string.concat(
                '<g id="q">',
                _letters(seed, bw / cell, bh / cell, cell),
                "</g>"
            );

            if (mirror == 2 || mirror == 3)
                content = string.concat(
                    content,
                    '<use href="#q" transform="translate(',
                    uint2str(bw),
                    ',0) scale(-1,1)"/>'
                );
            if (mirror == 1 || mirror == 3)
                content = string.concat(
                    content,
                    '<use href="#q" transform="translate(0,',
                    uint2str(bh),
                    ') scale(1,-1)"/>'
                );
            if (mirror == 3)
                content = string.concat(
                    content,
                    '<use href="#q" transform="translate(',
                    uint2str(bw),
                    ",",
                    uint2str(bh),
                    ') scale(-1,-1)"/>'
                );

            uint256 offX = (480 -
                ((mirror == 2 || mirror == 3) ? 2 * bw : bw)) / 2;
            uint256 offY = (480 -
                ((mirror == 1 || mirror == 3) ? 2 * bh : bh)) / 2;

            return
                string.concat(
                    svgHead,
                    '<g transform="translate(',
                    uint2str(offX),
                    ",",
                    uint2str(offY),
                    ')">',
                    content,
                    "</g></svg>"
                );
        }
    }

    /* ===== header / defs ===== */
    function _header(
        string memory font,
        uint256 fontPx,
        uint256 seed,
        uint256 cell
    ) internal pure returns (string memory) {
        (string memory c0, string memory c1, string memory c2) = _palette(seed);
        string memory style = string.concat(
            "<style>",
            bytes(font).length > 0
                ? string.concat(
                    "@font-face{font-family:geom;src:url(data:application/font-woff2;base64,",
                    font,
                    ') format("woff2");}'
                )
                : "",
            ".letter{fill:none;stroke-width:1;stroke-dasharray:",
            uint2str(cell * 2),
            ";stroke-dashoffset:",
            uint2str(cell * 2),
            ";font-family:geom,monospace;font-size:",
            uint2str(fontPx),
            "px;stroke-linecap:round}",
            ".c0{stroke:",
            c0,
            "}.c1{stroke:",
            c1,
            "}.c2{stroke:",
            c2,
            "}",
            "@keyframes p{to{stroke-dashoffset:0}}",
            "</style>"
        );
        string memory bg = '<rect width="480" height="480" fill="black"/>';
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 480" preserveAspectRatio="xMinYMin meet">',
                style,
                bg
            );
    }

    /* ===== letters at origin ===== */
    function _letters(
        uint256 seed,
        uint256 w,
        uint256 h,
        uint256 cell
    ) internal pure returns (string memory out) {
        for (uint256 r; r < h; r++) {
            for (uint256 c; c < w; c++) {
                seed = uint256(keccak256(abi.encodePacked(seed, r, c)));
                if (seed % 100 < 30) {
                    uint256 x = c * cell + cell / 2;
                    uint256 y = r * cell + cell / 2;
                    string memory g = seed % 3 == 0 ? "G" : seed % 3 == 1
                        ? "H"
                        : "Z";
                    string memory cls = (seed >> 8) % 3 == 0
                        ? "c0"
                        : (seed >> 8) % 3 == 1
                        ? "c1"
                        : "c2";
                    uint256 dur = 1 + ((seed >> 16) % 3);
                    uint256 del = (seed >> 24) % 10;
                    out = string.concat(
                        out,
                        '<text class="letter ',
                        cls,
                        '" x="',
                        uint2str(x),
                        '" y="',
                        uint2str(y),
                        '" style="animation:p 2s linear infinite">',
                        '<animate attributeName="opacity" values="1;0.2;1" dur="',
                        uint2str(dur),
                        's" begin="0.',
                        uint2str(del),
                        's" repeatCount="indefinite"/>',
                        g,
                        "</text>"
                    );
                }
            }
        }
    }

    /* ===== single glyph ===== */
    function _glyph(
        uint256 s,
        uint256 col,
        uint256 row,
        uint256 cell,
        uint256 ox,
        uint256 oy
    ) internal pure returns (string memory) {
        uint256 x = ox + col * cell + cell / 2;
        uint256 y = oy + row * cell + cell / 2;
        string memory g = s % 3 == 0 ? "G" : s % 3 == 1 ? "H" : "Z";
        string memory cls = (s >> 8) % 3 == 0 ? "c0" : (s >> 8) % 3 == 1
            ? "c1"
            : "c2";
        uint256 dur = 1 + ((s >> 16) % 3);
        uint256 del = (s >> 24) % 10;
        return
            string.concat(
                '<text class="letter ',
                cls,
                '" x="',
                uint2str(x),
                '" y="',
                uint2str(y),
                '" style="animation:p 2s linear infinite">',
                '<animate attributeName="opacity" values="1;0.2;1" dur="',
                uint2str(dur),
                's" begin="0.',
                uint2str(del),
                's" repeatCount="indefinite"/>',
                g,
                "</text>"
            );
    }

    /* ---------- palette ---------- */
    function _palette(
        uint256 s
    ) internal pure returns (string memory, string memory, string memory) {
        uint256 i = (s >> 4) % 3;
        if (i == 0) return ("#ff00ff", "#00ffff", "#ffff00");
        if (i == 1) return ("#ff0000", "#00ff00", "#0000ff");
        return ("#ffff00", "#00ffff", "#00ff00");
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
