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

    function renderSVG(uint tokenId) public view returns (string memory) {
        // Get the font data
        string memory base64Font = getFontData();

        // Create SVG with 20x20 grid of random G, H, Z letters
        return createRandomGridSVG(tokenId, base64Font);
    }

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

    /* -------------------------------------------------------------------------- */
    /*  1. createRandomGridSVG                                                    */
    /* -------------------------------------------------------------------------- */
    function createRandomGridSVG(
        uint256 tokenId,
        string memory base64Font
    ) internal pure returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(tokenId)));
        uint256 hue = seed % 360;

        /* static header first */
        string memory svgHeader = createSVGHeader(base64Font, hue, 25);

        /* filter for this token */
        string[3] memory mats = ["liqF", "glassF", "metalF"];
        string memory chosenFilter = mats[(seed >> 12) % 3];

        /* one gradient for this token */
        string memory gradId = string.concat("g", toString(tokenId));
        string memory grad = buildTokenGradient(gradId, hue);

        /* glyphs */
        string memory gridLetters = generateGridLetters(seed, 20, 25, 12);

        /* wrap grid */
        string memory wrapped = string.concat(
            '<g filter="url(#',
            chosenFilter,
            ')" fill="url(#',
            gradId,
            ')">',
            gridLetters,
            "</g>"
        );

        return string.concat(svgHeader, grad, wrapped, "</svg>");
    }

    /* -------------------------------------------------------------------------- */
    /*  2. createSVGHeader                                                        */
    /* -------------------------------------------------------------------------- */
    function createSVGHeader(
        string memory base64Font,
        uint256 hue, // kept for call-site compatibility
        uint256 fontSize
    ) internal pure returns (string memory) {
        /* svg start + background ---------------------------------------------- */
        string memory svgStart = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" ',
            'xmlns:xlink="http://www.w3.org/1999/xlink" ',
            'preserveAspectRatio="xMinYMin meet" viewBox="0 0 500 500">',
            '<rect width="500" height="500" fill="black"/>'
        );

        /* ─────----  (remove duplicate per-token gradient block)  ----───── */

        /* optional @font-face -------------------------------------------------- */
        string memory fontFace = bytes(base64Font).length > 0
            ? string.concat(
                '@font-face{font-family:"geom2regular";',
                "src:url(data:application/font-woff2;base64,",
                base64Font,
                ') format("woff2");font-weight:normal;font-style:normal;} '
            )
            : "";

        /* base glyph style ----------------------------------------------------- */
        string memory letterStyle = string.concat(
            ".letter{font-family:geom2regular,monospace;font-size:",
            toString(fontSize),
            "px;fill:url(#metalGrad);text-anchor:middle;dominant-baseline:middle;} "
        );

        string memory styleBlock = string.concat(
            "<defs><style>",
            "@keyframes p{to{stroke-dashoffset:0}} ",
            fontFace,
            letterStyle,
            "</style>"
        );

        /* gradients + filters --------------------------------------------------- */
        string memory filters = string.concat(
            /* ───── gradient (will tint glass & metal) ───── */
            '<linearGradient id="metalGrad" x1="0" y1="0" x2="0" y2="1">',
            '<stop offset="0%"  stop-color="#e9e9e9"/>',
            '<stop offset="50%" stop-color="#b0b0b0"/>',
            '<stop offset="100%" stop-color="#00ff00"/>',
            "</linearGradient>",
            /* ───── METAL ───── */
            '<filter id="metalF" x="-25%" y="-25%" width="150%" height="150%" ',
            'filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">',
            '<feTurbulence type="fractalNoise" baseFrequency="0.2 0.2" numOctaves="4" seed="2" result="noise"/>',
            '<feColorMatrix in="noise" type="saturate" values="0"/>',
            '<feBlend in="SourceGraphic" in2="noise" mode="overlay" result="bump"/>',
            '<feGaussianBlur in="bump" stdDeviation="0.6" result="blur"/>',
            '<feSpecularLighting in="blur" surfaceScale="6" specularExponent="50" lighting-color="#ffffff" result="spec">',
            '<fePointLight x="-300" y="-600" z="600"/>',
            "</feSpecularLighting>",
            '<feComposite in="spec" in2="SourceGraphic" operator="in" result="lit"/>',
            '<feBlend in="lit" in2="SourceGraphic" mode="screen"/>',
            "</filter>",
            /* ───── GLASS ───── */
            '<filter id="glassF" x="-5%" y="-5%" width="150%" height="150%" ',
            'filterUnits="userSpaceOnUse">',
            '<feGaussianBlur in="SourceAlpha" stdDeviation="1.8" result="blur"/>',
            '<feSpecularLighting in="blur" surfaceScale="3" specularExponent="45" lighting-color="#ffffff" result="spec">',
            '<fePointLight x="150" y="0" z="400"/>',
            "</feSpecularLighting>",
            '<feComposite in="spec" in2="SourceGraphic" operator="in" result="lit"/>',
            '<feComponentTransfer in="lit" result="thick">',
            '<feFuncA type="linear" slope="0.8"/>',
            "</feComponentTransfer>",
            '<feBlend in="SourceGraphic" in2="thick" mode="screen"/>',
            '<feColorMatrix type="matrix" values="0.9 0 0 0 0  0 0.9 0 0 0  0 0 0.9 0 0  0 0 0 1 0"/>',
            "</filter>",
            /* ───── LIQUID ───── */
            '<filter id="liqF" x="-20%" y="-20%" width="140%" height="140%" ',
            'filterUnits="userSpaceOnUse">',
            '<feTurbulence id="turb" type="turbulence" baseFrequency="0.025 0.05" numOctaves="3" seed="2" result="turb"/>',
            '<animate xlink:href="#turb" attributeName="baseFrequency" dur="8s" values="0.02 0.04;0.035 0.07;0.02 0.04" repeatCount="indefinite"/>',
            '<feDisplacementMap in="SourceGraphic" in2="turb" scale="12" xChannelSelector="R" yChannelSelector="G"/>',
            '<feGaussianBlur stdDeviation="0.8"/>',
            "</filter>",
            "</defs>"
        );

        return string.concat(svgStart, styleBlock, filters);
    }

    function buildTokenGradient(
        string memory gradId,
        uint256 hue
    ) internal pure returns (string memory) {
        string memory h0 = string.concat("hsl(", toString(hue), ",80%,85%)");
        string memory h1 = string.concat("hsl(", toString(hue), ",70%,55%)");
        string memory h2 = string.concat("hsl(", toString(hue), ",60%,25%)");

        return
            string.concat(
                '<linearGradient id="',
                gradId,
                '" x1="0" y1="0" x2="0" y2="1">',
                '<stop offset="0%"  stop-color="',
                h0,
                '"/>',
                '<stop offset="50%" stop-color="',
                h1,
                '"/>',
                '<stop offset="100%" stop-color="',
                h2,
                '"/>',
                "</linearGradient>"
            );
    }

    /* -------------------------------------------------------------------------- */
    /*  3. Generate Grid of Letters           */
    /* -------------------------------------------------------------------------- */

    function generateGridLetters(
        uint256 initialSeed,
        uint256 gridSize,
        uint256 cellSize,
        uint256 offset
    ) internal pure returns (string memory) {
        string memory letters = "";
        uint256 seed = initialSeed;

        for (uint256 i = 0; i < gridSize; i++) {
            for (uint256 j = 0; j < gridSize; j++) {
                // Update random seed
                seed = uint256(keccak256(abi.encodePacked(seed, i, j)));

                // 30% chance of placing a letter
                if (seed % 100 < 30) {
                    letters = string.concat(
                        letters,
                        createSingleLetter(seed, j, i, cellSize, offset)
                    );
                }
            }
        }

        return letters;
    }

    /* -------------------------------------------------------------------------- */
    /*  4. createSingleLetter – now calls buildTextElement with 4 args            */
    /* -------------------------------------------------------------------------- */

    function createSingleLetter(
        uint256 seed,
        uint256 col,
        uint256 row,
        uint256 cellSize,
        uint256 offset
    ) internal pure returns (string memory) {
        string[3] memory letters = ["G", "H", "Z"];
        string memory letter = letters[seed % 3];

        uint256 x = col * cellSize + offset;
        uint256 y = row * cellSize + offset + (offset / 2);

        uint256 animClass = 0; // placeholder

        return buildTextElement(letter, x, y, animClass);
    }

    /* -------------------------------------------------------------------------- */
    /*  5. buildTextElement – unchanged                                           */
    /* -------------------------------------------------------------------------- */
    function buildTextElement(
        string memory letter,
        uint256 x,
        uint256 y,
        uint256 animClass
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<text class="letter a',
                toString(animClass),
                '" x="',
                toString(x),
                '" y="',
                toString(y),
                '">',
                letter,
                "</text>"
            );
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
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
