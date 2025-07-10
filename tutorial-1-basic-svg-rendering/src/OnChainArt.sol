// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Random, RandomCtx} from "./utils/Random.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {QuadrantPlacement} from "./ShapePlacement.sol";
import {VisualCore} from "./VisualCore.sol";
import {RedCircles} from "./RedCircles.sol";
import {BlueDiamonds} from "./BlueDiamonds.sol";
import {GreenSquares} from "./GreenSquares.sol";
import {BasicShapes} from "./BasicShapes.sol";
import {NeonPortal} from "./NeonPortal.sol";

contract OnChainArt is ERC721 {
    VisualCore public immutable visualCore;
    RedCircles public immutable redCircles;
    BlueDiamonds public immutable blueDiamonds;
    GreenSquares public immutable greenSquares;
    BasicShapes public immutable basicShapes;
    NeonPortal public immutable neonPortal;

    constructor(
        address _visualCore,
        address _redCircles,
        address _blueDiamonds,
        address _greenSquares,
        address _basicShapes,
        address _neonPortal
    ) ERC721("On-chain Art", "ART") {
        visualCore = VisualCore(_visualCore);
        redCircles = RedCircles(_redCircles);
        blueDiamonds = BlueDiamonds(_blueDiamonds);
        greenSquares = GreenSquares(_greenSquares);
        basicShapes = BasicShapes(_basicShapes);
        neonPortal = NeonPortal(_neonPortal);
    }

    function mint(address to, uint256 id) external {
        _safeMint(to, id);
    }

    function _svg(uint256 tokenId) internal view returns (string memory) {
        (string memory colorA, string memory colorB, ) = _palette(tokenId);

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 1440 1440">',
                visualCore.createAllFilters(),
                visualCore.generateTextStyle(colorA, colorB),
                visualCore.generateBackground(tokenId, colorA),
                visualCore.createFrames(colorA, colorB),
                _generateAllShapes(tokenId),
                "</svg>"
            );
    }

    function _generateAllShapes(
        uint256 tokenId
    ) internal view returns (string memory) {
        QuadrantPlacement.PlacementPlan memory plan = QuadrantPlacement
            .generatePlacementPlan(tokenId);

        return
            string.concat(
                _generateRedCircles(tokenId, plan),
                // _generateSecondaryCluster(tokenId, plan),
                // _generateTertiaryClusters(tokenId, plan),
                _generatePinkSquares(tokenId, plan),
                _generateNeonPortal(tokenId)
            );
    }

    // function _generateNeonPortal(
    //     uint256 tokenId
    // ) internal view returns (string memory) {
    //     // Fixed center position and size for now
    //     uint16 centerX = 720;
    //     uint16 centerY = 720;
    //     uint16 portalSize = 380;
    //     bool enablePulse = (tokenId % 2) == 0; // 33% chance of pulsing

    //     return
    //         neonPortal.createNeonPortal(
    //             centerX,
    //             centerY,
    //             portalSize,
    //             tokenId,
    //             enablePulse
    //         );
    // }

    function _generateNeonPortal(
        uint256 tokenId
    ) internal view returns (string memory) {
        // Fixed center position and size for now
        uint16 centerX = 720;
        uint16 centerY = 720;
        uint8 portalSize = 80; // CHANGED: uint8 instead of uint16
        bool enablePulse = (tokenId % 3) == 0; // 33% chance of pulsing

        return
            neonPortal.createNeonPortal(
                centerX,
                centerY,
                portalSize, // Now correctly uint8
                tokenId,
                enablePulse
            );
    }

    function _generateRedCircles(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 12345);
        QuadrantPlacement.ShapeConfig[] memory circles = QuadrantPlacement
            .placeRedCircles(ctx, plan);

        string memory result = "";
        for (uint8 i = 0; i < circles.length; i++) {
            uint8 animationPattern = uint8((tokenId + i) % 3); // 0=linear, 1=orbit, 2=pulse
            uint256 seed = uint256(circles[i].x) +
                uint256(circles[i].y) +
                tokenId;

            result = string.concat(
                result,
                redCircles.createAnimatedCircle(
                    circles[i].x,
                    circles[i].y,
                    circles[i].size,
                    seed,
                    animationPattern
                )
            );
        }
        return result;
    }

    function _generateSecondaryCluster(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 23456);
        QuadrantPlacement.ShapeConfig[] memory cluster = QuadrantPlacement
            .placeSecondaryCluster(ctx, plan);

        string memory result = "";
        for (uint8 i = 0; i < cluster.length; i++) {
            uint256 seed = uint256(cluster[i].x) +
                uint256(cluster[i].y) +
                tokenId;
            bool enablePulse = (seed % 3) == 0; // ~33% get pulsing effect

            if (plan.secondaryShapeType == 1) {
                // Blue diamonds
                result = string.concat(
                    result,
                    blueDiamonds.createAnimatedDiamond(
                        cluster[i].x,
                        cluster[i].y,
                        cluster[i].size,
                        seed,
                        enablePulse
                    )
                );
            } else {
                // Green squares
                result = string.concat(
                    result,
                    greenSquares.createAnimatedSquare(
                        cluster[i].x,
                        cluster[i].y,
                        cluster[i].size,
                        seed,
                        enablePulse
                    )
                );
            }
        }
        return result;
    }

    function _generateTertiaryClusters(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 34567);
        QuadrantPlacement.ShapeConfig[] memory clusters = QuadrantPlacement
            .placeTertiaryClusters(ctx, plan);

        string memory result = "";
        for (uint8 i = 0; i < clusters.length; i++) {
            uint256 seed = uint256(clusters[i].x) +
                uint256(clusters[i].y) +
                tokenId;
            bool enablePulse = (seed % 4) == 0; // ~25% get pulsing effect

            // Tertiary uses opposite of secondary
            if (plan.secondaryShapeType == 1) {
                // Secondary was blue, so tertiary is green
                result = string.concat(
                    result,
                    greenSquares.createAnimatedSquare(
                        clusters[i].x,
                        clusters[i].y,
                        clusters[i].size,
                        seed,
                        enablePulse
                    )
                );
            } else {
                // Secondary was green, so tertiary is blue
                result = string.concat(
                    result,
                    blueDiamonds.createAnimatedDiamond(
                        clusters[i].x,
                        clusters[i].y,
                        clusters[i].size,
                        seed,
                        enablePulse
                    )
                );
            }
        }
        return result;
    }

    function _generatePinkSquares(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 45678);
        QuadrantPlacement.ShapeConfig[] memory pinks = QuadrantPlacement
            .placePinkSquares(ctx, plan);

        string memory result = "";
        for (uint8 i = 0; i < pinks.length; i++) {
            uint256 seed = uint256(pinks[i].x) + uint256(pinks[i].y) + tokenId;

            result = string.concat(
                result,
                basicShapes.createCrossSquare(
                    pinks[i].x,
                    pinks[i].y,
                    pinks[i].size,
                    seed
                )
            );
        }
        return result;
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

    function renderSVG(uint256 id) external view returns (string memory) {
        return _svg(id);
    }

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
