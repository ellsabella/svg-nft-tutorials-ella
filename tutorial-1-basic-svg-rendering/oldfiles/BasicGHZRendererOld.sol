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

    /* === public entry === */
    function renderSVG(uint256 tokenId) public view returns (string memory) {
        return createRandomGridSVG(tokenId, getFontData());
    }

    /* === main builder === */
    function createRandomGridSVG(
        uint256 tokenId,
        string memory base64Font
    ) internal pure returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(tokenId)));

        /* grid size 6 / 8 / 10 / 12 */
        uint256 grid = (seed & 3) == 0 ? 6 : (seed & 3) == 1
            ? 8
            : (seed & 3) == 2
            ? 10
            : 12;
        uint256 cell = 500 / grid;
        uint256 fontPx = (cell * 9) / 10; // 90% of cell
        uint256 off = (500 - cell * grid) / 2;
        uint256 q = grid / 2; // quarter used for mirroring

        /* build header + defs (re‑derive params inside to save stack) */
        uint256 pitch = 2 + ((seed >> 56) & 7);
        string memory header = createSVGHeader(base64Font, fontPx, pitch, seed);

        /* choose main artistic filter */
        uint256 a = (seed >> 60) & 3;
        string memory mainF = a == 0 ? "glitchF" : a == 1
            ? "neonF"
            : "channelF";

        /* optional scanline overlay */
        string memory scan = "";
        uint256 sc = (seed >> 64) & 3;
        if (sc != 0) {
            scan = string.concat(
                '<rect width="500" height="500" fill="url(#',
                sc == 1 ? "scanG" : "scanP",
                ')" opacity="0.08"/>'
            );
        }

        /* quarter grid letters then mirror */
        string memory qSVG = generateQuarterLetters(seed, q, cell, off);
        string memory mirrored = string.concat(
            '<g id="q">',
            qSVG,
            "</g>",
            '<use href="#q"/>',
            '<use href="#q" transform="scale(-1,1) translate(-500,0)"/>',
            '<use href="#q" transform="scale(1,-1) translate(0,-500)"/>',
            '<use href="#q" transform="scale(-1,-1) translate(-500,-500)"/>'
        );

        return
            string.concat(
                header,
                scan,
                '<g filter="url(#',
                mainF,
                ')">',
                mirrored,
                "</g></svg>"
            );
    }

    /* === header & defs === */
    function createSVGHeader(
        string memory base64Font,
        uint256 fontSize,
        uint256 pitch,
        uint256 seed
    ) internal pure returns (string memory) {
        string
            memory svgStart = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500"><rect width="500" height="500" fill="black"/>';

        string memory fontFace = bytes(base64Font).length > 0
            ? string.concat(
                '@font-face{font-family:"geom2regular";src:url(data:application/font-woff2;base64,',
                base64Font,
                ') format("woff2");}'
            )
            : "";

        // palette + filter params derived locally (no extra stack at caller)
        (string memory c0, string memory c1, string memory c2) = pickPalette(
            seed
        );
        uint256 dScale = 4 + ((seed >> 32) & 0xF);
        uint256 blurPx = 1 + ((seed >> 40) & 3);
        int256 dxRGB = int256(int8(int((seed >> 48) % 5) - 2));
        string memory dxStr = intToString(dxRGB);

        // <style>
        string memory style = string.concat(
            "<style>",
            fontFace,
            "@keyframes p{to{stroke-dashoffset:0}}",
            ".letter{fill:none;stroke-width:1;stroke-linecap:round;stroke-dasharray:50;stroke-dashoffset:50;font-family:geom2regular,monospace;font-size:",
            toString(fontSize),
            "px;}",
            ".c0{stroke:",
            c0,
            ";}.c1{stroke:",
            c1,
            ";}.c2{stroke:",
            c2,
            ";}",
            "</style>"
        );

        // scanline pattern (green)
        string memory scanG = string.concat(
            '<pattern id="scanG" width="4" height="',
            toString(pitch),
            '" patternUnits="userSpaceOnUse">',
            '<rect width="4" height="1" fill="#00ff00"/>',
            '<animateTransform attributeName="patternTransform" type="translate" from="0 0" to="0 ',
            toString(pitch),
            '" dur="0.4s" repeatCount="indefinite"/>',
            "</pattern>"
        );

        // assemble <defs>
        string memory defs = string.concat(
            "<defs>",
            style,
            scanG,
            '<pattern id="scanP" width="4" height="4" patternUnits="userSpaceOnUse"><rect width="4" height="1" fill="#ff00ff"/></pattern>',
            '<filter id="glitchF" x="-20%" y="-20%" width="140%" height="140%">',
            '<feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="1" seed="2" result="t"/>',
            '<feDisplacementMap in="SourceGraphic" in2="t" scale="',
            toString(dScale),
            '" xChannelSelector="R" yChannelSelector="G"/>',
            "</filter>",
            '<filter id="neonF" x="-20%" y="-20%" width="140%" height="140%">',
            '<feGaussianBlur stdDeviation="',
            toString(blurPx),
            '" result="b"/>',
            '<feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>',
            "</filter>",
            '<filter id="channelF" x="-20%" y="-20%" width="140%" height="140%" color-interpolation-filters="sRGB">',
            '<feOffset dx="',
            dxStr,
            '" dy="0" result="r"/>',
            '<feComponentTransfer in="r">',
            '<feFuncR type="linear" slope="1"/>',
            '<feFuncG type="linear" slope="0"/>',
            '<feFuncB type="linear" slope="0"/>',
            '<feFuncA type="linear" slope="1"/>',
            "</feComponentTransfer>",
            '<feMerge><feMergeNode in="SourceGraphic"/><feMergeNode in="r"/></feMerge>',
            "</filter>",
            "</defs>"
        );

        return string.concat(svgStart, defs);
    }

    /* === quarter letters === */
    function generateQuarterLetters(
        uint256 seed,
        uint256 q,
        uint256 cell,
        uint256 off
    ) internal pure returns (string memory out) {
        for (uint256 r; r < q; r++) {
            for (uint256 c; c < q; c++) {
                seed = uint256(keccak256(abi.encodePacked(seed, r, c)));
                if (seed % 100 < 60) {
                    out = string.concat(
                        out,
                        buildLetter(seed, c, r, cell, off)
                    );
                }
            }
        }
    }

    /* === single glyph === */
    function buildLetter(
        uint256 s,
        uint256 col,
        uint256 row,
        uint256 cell,
        uint256 off
    ) internal pure returns (string memory) {
        uint256 x = col * cell + off + cell / 2;
        uint256 y = row * cell + off + cell / 2;
        string memory glyph = s % 3 == 0 ? "G" : s % 3 == 1 ? "H" : "Z";
        string memory cls = ((s >> 8) % 3) == 0 ? "c0" : ((s >> 8) % 3) == 1
            ? "c1"
            : "c2";
        uint256 dur = 5 + ((s >> 16) % 3);
        uint256 delay = (s >> 24) % 10;

        return
            string.concat(
                '<text class="letter ',
                cls,
                '" x="',
                toString(x),
                '" y="',
                toString(y),
                '" style="animation:p 5s linear infinite">',
                '<animate attributeName="opacity" values="1;0.2;1" dur="',
                toString(dur),
                's" begin="0.',
                toString(delay),
                's" repeatCount="indefinite"/>',
                glyph,
                "</text>"
            );
    }

    /* === palette === */
    function pickPalette(
        uint256 s
    ) internal pure returns (string memory, string memory, string memory) {
        uint256 i = (s >> 4) % 3;
        if (i == 0) return ("#ff00ff", "#00ffff", "#ffff00");
        if (i == 1) return ("#ff0000", "#00ff00", "#0000ff");
        return ("#ffff00", "#00ffff", "#00ff00");
    }

    /* === helpers === */
    function toString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 l = v;
        uint256 digits;
        while (l != 0) {
            digits++;
            l /= 10;
        }
        bytes memory buf = new bytes(digits);
        while (v != 0) {
            digits--;
            buf[digits] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        return string(buf);
    }

    function intToString(int256 i) internal pure returns (string memory) {
        return
            i >= 0
                ? toString(uint256(i))
                : string.concat("-", toString(uint256(-i)));
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
}
