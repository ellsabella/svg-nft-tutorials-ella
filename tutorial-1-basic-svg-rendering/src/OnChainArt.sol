// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Random, RandomCtx} from "./utils/Random.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {QuadrantPlacement} from "./ShapePlacement.sol";
import {VisualCore} from "./VisualCore.sol";
import {CircularShapes} from "./CircularShapes.sol";
import {CircleTypes} from "./CircleTypes.sol";
import {BlueDiamonds} from "./BlueDiamonds.sol";
import {GreenSquares} from "./GreenSquares.sol";
import {BasicShapes} from "./BasicShapes.sol";

contract OnChainArt is ERC721 {
    VisualCore public immutable visualCore;
    CircularShapes public immutable circularShapes;
    BlueDiamonds public immutable blueDiamonds;
    GreenSquares public immutable greenSquares;
    BasicShapes public immutable basicShapes;

    constructor(
        address _visualCore,
        address _circularShapes,
        address _blueDiamonds,
        address _greenSquares,
        address _basicShapes
    ) ERC721("On-chain Art", "ART") {
        visualCore = VisualCore(_visualCore);
        circularShapes = CircularShapes(_circularShapes);
        blueDiamonds = BlueDiamonds(_blueDiamonds);
        greenSquares = GreenSquares(_greenSquares);
        basicShapes = BasicShapes(_basicShapes);
    }

    function mint(address to, uint256 id) external {
        _safeMint(to, id);
    }

    function _svg(uint256 tokenId) internal view returns (string memory) {
        (string memory colorA, string memory colorB, ) = _palette(tokenId);

        string memory filters = visualCore.createAllFilters(tokenId);
        string memory textStyle = visualCore.generateTextStyle(colorA, colorB);
        string memory background = visualCore.generateBackground(
            tokenId,
            colorA,
            colorB
        );
        string memory frames = visualCore.createFrames();
        string memory shapes = _generateAllShapes(tokenId, colorA, colorB);

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 1440 1440">',
                filters,
                textStyle,
                background,
                frames,
                shapes,
                "</svg>"
            );
    }

    function _generateAllShapes(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) internal view returns (string memory) {
        QuadrantPlacement.PlacementPlan memory plan = QuadrantPlacement
            .generatePlacementPlan(tokenId);

        string memory redCircles = _generateRedCircles(
            tokenId,
            plan,
            colorA,
            colorB
        );
        string memory neonPortals = _generateNeonPortals(
            tokenId,
            colorA,
            colorB
        );
        string memory pinkSquares = _generatePinkSquares(tokenId, plan);
        string memory blueDiamonds = _generateBlueDiamonds(tokenId, plan);
        string memory greenSquares = _generateGreenSquares(tokenId, plan);

        return
            string.concat(
                redCircles,
                neonPortals,
                pinkSquares,
                blueDiamonds,
                greenSquares
            );
    }

    function _generateRedCircles(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan,
        string memory colorA,
        string memory colorB
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 12345);
        QuadrantPlacement.ShapeConfig[] memory circles = QuadrantPlacement
            .placeRedCircles(ctx, plan);

        (
            string memory paletteColorA,
            string memory paletteColorB,
            string memory paletteColorC
        ) = _palette(tokenId);

        string memory result = "";
        for (uint8 i = 0; i < circles.length; i++) {
            uint256 seed = uint256(circles[i].x) +
                uint256(circles[i].y) +
                tokenId;

            // Red circles: solid color, no gradient, no glitch
            result = string.concat(
                result,
                circularShapes.createCircle(
                    CircleTypes.Config({
                        x: circles[i].x,
                        y: circles[i].y,
                        size: circles[i].size,
                        seed: seed,
                        useGradient: false,
                        enableGlitch: false
                    }),
                    // OLD COLORS (commented out):
                    // "#FF4444", // red color
                    // "#FFAA44"  // amber color (unused for solid)

                    // NEW PALETTE-BASED COLORS:
                    paletteColorA, // first color from palette for smaller circles
                    paletteColorA // unused for solid color
                )
            );
        }
        return result;
    }

    function _generateBlueDiamonds(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 23456);
        QuadrantPlacement.ShapeConfig[]
            memory secondaryShapes = QuadrantPlacement.placeSecondaryCluster(
                ctx,
                plan
            );

        string memory result = "";
        // Only render if secondary shape type is diamonds (type 1)
        if (plan.secondaryShapeType == 1) {
            for (uint8 i = 0; i < secondaryShapes.length; i++) {
                uint256 seed = uint256(secondaryShapes[i].x) +
                    uint256(secondaryShapes[i].y) +
                    tokenId;
                bool enablePulse = (seed % 4) == 0; // 25% chance of pulse

                result = string.concat(
                    result,
                    blueDiamonds.createAnimatedDiamond(
                        secondaryShapes[i].x,
                        secondaryShapes[i].y,
                        secondaryShapes[i].size,
                        seed,
                        enablePulse
                    )
                );
            }
        }
        return result;
    }

    function _generateGreenSquares(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 34567);
        QuadrantPlacement.ShapeConfig[]
            memory tertiaryShapes = QuadrantPlacement.placeTertiaryClusters(
                ctx,
                plan
            );

        string memory result = "";
        // Only render if tertiary shape type is squares (type 2)
        // Tertiary type is opposite of secondary: if secondary=1 (diamonds), tertiary=2 (squares)
        uint8 tertiaryType = (plan.secondaryShapeType == 1) ? 2 : 1;
        if (tertiaryType == 2) {
            for (uint8 i = 0; i < tertiaryShapes.length; i++) {
                uint256 seed = uint256(tertiaryShapes[i].x) +
                    uint256(tertiaryShapes[i].y) +
                    tokenId;
                bool enablePulse = (seed % 3) == 0; // 33% chance of pulse

                result = string.concat(
                    result,
                    greenSquares.createAnimatedSquare(
                        tertiaryShapes[i].x,
                        tertiaryShapes[i].y,
                        tertiaryShapes[i].size,
                        seed,
                        enablePulse
                    )
                );
            }
        }
        return result;
    }

    function _generateNeonPortals(
        uint256 tokenId,
        string memory colorA,
        string memory colorB
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 99999);

        uint16 portalSize = 300 + uint16(Random.randInt(ctx) % 601); // 300-900 range
        uint8 numPortals = 1 + uint8(Random.randInt(ctx) % 3); // 1-3 portals

        (
            string memory paletteColorA,
            string memory paletteColorB,
            string memory paletteColorC
        ) = _palette(tokenId);

        string memory result = "";

        for (uint8 i = 0; i < numPortals; i++) {
            (uint16 x, uint16 y) = _getSafePortalPosition(ctx, i, numPortals);
            uint256 seed = tokenId + uint256(i);
            bool enableGlitch = (seed % 2) == 0; // 50% chance of glitch

            // Neon portals: gradient, palette colors, optional glitch
            result = string.concat(
                result,
                circularShapes.createCircle(
                    CircleTypes.Config({
                        x: x,
                        y: y,
                        size: portalSize,
                        seed: seed,
                        useGradient: true,
                        enableGlitch: enableGlitch
                    }),
                    // OLD COLORS (commented out):
                    // "#00FFFF", // cyan
                    // "#FF00FF"  // magenta

                    // NEW PALETTE-BASED COLORS:
                    paletteColorB, // second color from palette for big circles
                    paletteColorC // third color from palette for big circles
                )
            );
        }

        return result;
    }

    function _getSafePortalPosition(
        RandomCtx memory ctx,
        uint8 portalIndex,
        uint8 totalPortals
    ) internal pure returns (uint16, uint16) {
        if (totalPortals == 1) {
            return (
                200 + uint16(Random.randInt(ctx) % 1040),
                200 + uint16(Random.randInt(ctx) % 1040)
            );
        } else if (totalPortals == 2) {
            if (portalIndex == 0) {
                return (
                    200 + uint16(Random.randInt(ctx) % 400),
                    200 + uint16(Random.randInt(ctx) % 1040)
                );
            } else {
                return (
                    840 + uint16(Random.randInt(ctx) % 400),
                    200 + uint16(Random.randInt(ctx) % 1040)
                );
            }
        } else {
            if (portalIndex == 0) {
                return (400, 400);
            } else if (portalIndex == 1) {
                return (1040, 400);
            } else {
                return (720, 1040);
            }
        }
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
        if (i == 3) return ("#FF0000", "#00FF00", "#00FF00");
        if (i == 4) return ("#00FFFF", "#FF00FF", "#FFFF00");
        return ("#00FFFF", "#00FF00", "#FF00FF");
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
