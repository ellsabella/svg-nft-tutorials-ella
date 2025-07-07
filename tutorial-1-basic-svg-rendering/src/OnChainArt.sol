// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Random, RandomCtx} from "./utils/Random.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ShapeFactory, IShapeRenderer, CircleRenderer, DiamondRenderer, SquareDiamondRenderer, CrossSquareRenderer} from "./ShapeFactory.sol";
import {ASCIIGenerator, IASCIIGenerator} from "./ASCIIGenerator.sol";
import {NeonEffects, INeonEffects} from "./NeonEffects.sol";
import {QuadrantPlacement} from "./ShapePlacement.sol";
import {IAnimations, Animations} from "./Animations.sol";

contract OnChainArt is ERC721 {
    ShapeFactory public immutable shapeFactory;
    ASCIIGenerator public immutable asciiGenerator;
    NeonEffects public immutable neonEffects;
    Animations public immutable animations;

    constructor(
        address _shapeFactory,
        address _asciiGenerator,
        address _neonEffects,
        address _animations
    ) ERC721("On-chain Art", "ART") {
        shapeFactory = ShapeFactory(_shapeFactory);
        asciiGenerator = ASCIIGenerator(_asciiGenerator);
        neonEffects = NeonEffects(_neonEffects);
        animations = Animations(_animations);
    }

    function mint(address to, uint256 id) external {
        _safeMint(to, id);
    }

    function _generateAllShapes(
        uint256 tokenId
    ) internal view returns (string memory) {
        QuadrantPlacement.PlacementPlan memory plan = QuadrantPlacement
            .generatePlacementPlan(tokenId);

        return
            string.concat(
                _generateRedCircles(tokenId, plan),
                _generateSecondaryCluster(tokenId, plan),
                _generateTertiaryClusters(tokenId, plan),
                _generatePinkSquares(tokenId, plan)
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
            // Generate animation parameters
            IAnimations.AnimationParams memory animParams = animations
                .createRedCircleAnimation(
                    tokenId,
                    uint256(i),
                    circles[i].x,
                    circles[i].y,
                    circles[i].size
                );

            // Create animated circle with white hot stroke included
            string memory animatedCircle = animations.generateAnimatedCircle(
                circles[i].x,
                circles[i].y,
                circles[i].size,
                "#FF4444",
                animParams
            );

            result = string.concat(result, animatedCircle);
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

        string memory color = plan.secondaryShapeType == 1
            ? "#44DDFF"
            : "#44FF44";
        INeonEffects.GlowIntensity glow = plan.secondaryShapeType == 1
            ? INeonEffects.GlowIntensity.STATIC
            : INeonEffects.GlowIntensity.PULSE_FAST;

        string memory result = "";
        for (uint8 i = 0; i < cluster.length; i++) {
            result = string.concat(
                result,
                _createShapeFromConfig(cluster[i], color, glow)
            );
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

        string memory color = plan.secondaryShapeType == 1
            ? "#44FF44"
            : "#44DDFF";
        INeonEffects.GlowIntensity glow = plan.secondaryShapeType == 1
            ? INeonEffects.GlowIntensity.PULSE_FAST
            : INeonEffects.GlowIntensity.STATIC;

        string memory result = "";
        for (uint8 i = 0; i < clusters.length; i++) {
            result = string.concat(
                result,
                _createShapeFromConfig(clusters[i], color, glow)
            );
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
            result = string.concat(
                result,
                _createShapeFromConfig(
                    pinks[i],
                    "#FF44FF",
                    INeonEffects.GlowIntensity.STATIC
                )
            );
        }
        return result;
    }

    // NEW FUNCTION: Replaces your old _createShape
    function _createShapeFromConfig(
        QuadrantPlacement.ShapeConfig memory config,
        string memory color,
        INeonEffects.GlowIntensity intensity
    ) internal view returns (string memory) {
        IShapeRenderer.ShapeParams memory params = IShapeRenderer.ShapeParams({
            x: uint256(config.x),
            y: uint256(config.y),
            color: color,
            seed: uint256(config.x) + uint256(config.y),
            size: uint256(config.size)
        });

        string memory baseShape = shapeFactory.renderShape(
            config.shapeType,
            params
        );

        string memory coreShape = string.concat(
            '<g filter="url(#blur)">',
            baseShape,
            "</g>",
            "<g>",
            baseShape,
            "</g>"
        );

        if (neonEffects.isPulsing(intensity)) {
            return
                _wrapWithPulse(
                    coreShape,
                    intensity,
                    config.shapeType,
                    uint256(config.x),
                    uint256(config.y),
                    uint256(config.x) + uint256(config.y), // Simple seed
                    uint256(config.size) // PASS SIZE
                );
        }

        return coreShape;
    }

    // UPDATED: Add size parameter to match NeonEffects interface
    function _wrapWithPulse(
        string memory coreShape,
        INeonEffects.GlowIntensity intensity,
        uint256 shapeType,
        uint256 x,
        uint256 y,
        uint256 seed,
        uint256 size // ADD SIZE PARAMETER
    ) internal view returns (string memory) {
        string memory duration = intensity ==
            INeonEffects.GlowIntensity.PULSE_FAST
            ? "1"
            : intensity == INeonEffects.GlowIntensity.PULSE_SLOW
            ? "3"
            : "2";

        string memory whiteStroke = neonEffects.createWhiteHotStroke(
            shapeType,
            x,
            y,
            intensity,
            seed,
            size // PASS SIZE TO NEON EFFECTS
        );

        return
            string.concat(
                "<g>",
                coreShape,
                '<g filter="url(#blur)" stroke-opacity="0.4">',
                whiteStroke,
                '<animate attributeName="opacity" values="0;0.6;0" dur="',
                duration,
                's" repeatCount="indefinite"/>',
                "</g>",
                "</g>"
            );
    }

    // Keep all existing functions unchanged
    function _svg(uint256 tokenId) internal view returns (string memory) {
        (string memory A, string memory B, ) = _palette(tokenId);

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 1440 1440">',
                neonEffects.createEnhancedFilters(),
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
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
                colorA,
                '" stroke-width="10" filter="url(#blur)"/>',
                '<rect x="30" y="30" width="1380" height="1380" fill="none" stroke="',
                colorA,
                '" stroke-width="10"/>',
                '<rect x="60" y="60" width="1320" height="1320" fill="none" stroke="',
                colorB,
                '" stroke-width="10" filter="url(#blur)"/>',
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
                '<rect width="1440" height="1440" fill="black"/>',
                '<rect width="1440" height="1440" fill="none" stroke="#333" stroke-width="1" opacity="0.2"/>'
            );
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
