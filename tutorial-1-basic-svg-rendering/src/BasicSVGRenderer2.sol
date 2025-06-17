// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Utils} from "./Utils.sol";
import {Random, RandomCtx} from "./Random.sol";

/**
 * @author Eto Vass
 */

interface IFileStore {
    function getFile(string memory filename) external view returns (File memory file);
    function fileExists(string memory filename) external view returns (bool);
}

struct File {
    function read() external view returns (string memory);
}

/**
 * @title Basic G,H,Z Font Renderer
 * @notice Simple implementation to display G, H, and Z using font from ETHFS
 */
contract BasicGHZRenderer {
    IFileStore constant fileStore = IFileStore(0x9746fD0A77829E12F8A9DBe70D7a322412325B91);
    
    function renderSVG(uint tokenId) public view returns (string memory) {
        // Get the font data from ETHFS
        string memory base64Font = getFontData();
        
        // Create SVG with G, H, Z letters
        return createSVGWithLetters(base64Font);
    }
    
    function getFontData() internal view returns (string memory) {
        string memory fontFileName = "ghz.txt.txt";
        
        if (fileStore.fileExists(fontFileName)) {
            File memory fontFile = fileStore.getFile(fontFileName);
            return fontFile.read();
        }
        
        return ""; // Return empty if font not found
    }
    
    function createSVGWithLetters(string memory base64Font) 
        internal pure returns (string memory) {
        
        // SVG start
        string memory svgStart = '<svg xmlns="http://www.w3.org/2000/svg" '
            'preserveAspectRatio="xMinYMin meet" viewBox="0 0 512 512">';
        
        // Font definition (only if we have font data)
        string memory fontDef = "";
        if (bytes(base64Font).length > 0) {
            fontDef = string.concat(
                '<defs><style>',
                '@font-face { font-family: "Geom2"; ',
                'src: url(data:font/woff2;base64,', base64Font, '); }',
                '</style></defs>'
            );
        }
        
        // Create text elements for G, H, Z
        string memory textElements = string.concat(
            // Letter G
            '<text font-family="Geom2, serif" ',
            'font-size="72" ',
            'x="128" y="200" ',
            'fill="hsl(120, 70%, 50%)" ',
            'text-anchor="middle" ',
            'dominant-baseline="middle">G</text>',
            
            // Letter H  
            '<text font-family="Geom2, serif" ',
            'font-size="72" ',
            'x="256" y="200" ',
            'fill="hsl(240, 70%, 50%)" ',
            'text-anchor="middle" ',
            'dominant-baseline="middle">H</text>',
            
            // Letter Z
            '<text font-family="Geom2, serif" ',
            'font-size="72" ',
            'x="384" y="200" ',
            'fill="hsl(0, 70%, 50%)" ',
            'text-anchor="middle" ',
            'dominant-baseline="middle">Z</text>'
        );
        
        // Close SVG
        string memory svgEnd = '</svg>';
        
        return string.concat(svgStart, fontDef, textElements, svgEnd);
    }
    
    // Helper function to test if font file exists
    function fontExists() external view returns (bool) {
        return fileStore.fileExists("ghz.txt.txt");
    }
    
    // Helper function to get font data for debugging
    function getFontDataForTesting() external view returns (string memory) {
        return getFontData();
    }
    
    // Simple version without font (fallback)
    function renderSVGWithoutFont() external pure returns (string memory) {
        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">',
            '<text font-family="serif" font-size="72" x="128" y="200" fill="green" text-anchor="middle">G</text>',
            '<text font-family="serif" font-size="72" x="256" y="200" fill="blue" text-anchor="middle">H</text>',
            '<text font-family="serif" font-size="72" x="384" y="200" fill="red" text-anchor="middle">Z</text>',
            '</svg>'
        );
    }
}

// contract BasicSVGRenderer {
//     function renderSVG(uint tokenId) public pure returns (string memory) {
//         RandomCtx memory ctx = Random.initCtx(tokenId);

//         string memory circles = "";

//         int hue = Random.randRange(ctx, 0, 359);

//         for (uint i = 0; i < 10; i++) {
//             int cx = Random.randRange(ctx, 0, 512);
//             int cy = Random.randRange(ctx, 0, 512);
//             int r = Random.randRange(ctx, 24, 64);
//             int sat = Random.randRange(ctx, 0, 100);
//             int opacity = Random.randRange(ctx, 10, 99);

//             circles = string.concat(
//                 circles,
//                 '<circle cx="',
//                 Utils.toString(cx),
//                 '" cy="',
//                 Utils.toString(cy),
//                 '" r="',
//                 Utils.toString(r),
//                 '" fill="hsl(',
//                 Utils.toString(hue),
//                 ",",
//                 Utils.toString(sat),
//                 '%, 50%)" opacity="0.',
//                 Utils.toString(opacity),
//                 '"/>'
//             );
//         }

//         return
//             string.concat(
//                 '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 512 512">',
//                 circles,
//                 "</svg>"
//             );
//     }
// }
