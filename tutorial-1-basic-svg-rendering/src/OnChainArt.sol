// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Random, RandomCtx} from "./utils/Random.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ShapeFactory, IShapeRenderer, CircleRenderer, DiamondRenderer, SquareDiamondRenderer, CrossSquareRenderer} from "./ShapeFactory.sol";
import {ASCIIGenerator, IASCIIGenerator} from "./ASCIIGenerator.sol";
import {NeonEffects, INeonEffects} from "./NeonEffects.sol";

contract OnChainArt is ERC721 {
    ShapeFactory public immutable shapeFactory;
    ASCIIGenerator public immutable asciiGenerator;
    NeonEffects public immutable neonEffects;

    constructor(
        address _shapeFactory,
        address _asciiGenerator,
        address _neonEffects
    ) ERC721("On-chain Art", "ART") {
        shapeFactory = ShapeFactory(_shapeFactory);
        asciiGenerator = ASCIIGenerator(_asciiGenerator);
        neonEffects = NeonEffects(_neonEffects); // ADD THIS
    }

    function mint(address to, uint256 id) external {
        _safeMint(to, id);
    }

    function _generateAllShapes(
        uint256 tokenId
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId);
        uint256 normalCount = 16 + (Random.randInt(ctx) % 16); // 16-32 shapes
        return shapeFactory.generateShapes(tokenId, normalCount);
    }

    function _svg(uint256 tokenId) internal view returns (string memory) {
        (string memory A, string memory B, ) = _palette(tokenId);

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 1440 1440">',
                neonEffects.createEnhancedFilters(), // CHANGE THIS LINE
                asciiGenerator.generateTextStyle(A, B),
                _createMirroredBackground(),
                asciiGenerator.generateTextBackground(tokenId, A),
                _createDoubleFrame(A, B),
                _generateAllShapes(tokenId),
                "</svg>"
            );
    }

    function _createDoubleFrame(
        string memory colorA,
        string memory colorB
    ) internal view returns (string memory) {
        return
            string.concat(
                // Outer frame - glow layer
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
                colorA,
                '" stroke-width="10" filter="url(#blur)"/>',
                // Outer frame - crisp overlay
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
                colorA,
                '" stroke-width="10"/>',
                // Inner frame - glow layer
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="',
                colorB,
                '" stroke-width="10" filter="url(#blur)"/>',
                // Inner frame - crisp overlay
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="',
                colorB,
                '" stroke-width="10"/>'
            );
    }

    function _palette(
        uint256 tokenId
    ) internal view returns (string memory, string memory, string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId);
        uint256 i = Random.randInt(ctx) % 6;
        if (i == 0) return ("#FFFF00", "#FF00FF", "#FFFF00");
        if (i == 1) return ("#FF0000", "#FFFF00", "#00FF00");
        if (i == 2) return ("#FF0000", "#00FFFF", "#FFFF00");
        if (i == 3) return ("#FF0000", "#00FFFF", "#00FF00");
        if (i == 4) return ("#00FFFF", "#FF00FF", "#FFFF00");
        return ("#00FFFF", "#FFFF00", "#00FF00");
    }

    function _createMirroredBackground() internal view returns (string memory) {
        return
            string.concat(
                // Basic black background first
                '<rect width="1440" height="1440" fill="black"/>',
                // Simple grid overlay for now
                '<rect width="1440" height="1440" fill="none" stroke="#333" stroke-width="1" opacity="0.2"/>'
            );
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
