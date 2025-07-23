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

    // Portal configuration constants
    uint16 constant MIN_PORTAL_RADIUS = 300;
    uint16 constant MAX_PORTAL_RADIUS = 900;
    uint16 constant CENTER_X = 720;
    uint16 constant CENTER_Y = 720;
    uint16 constant CENTER_RADIUS = 720;

    struct PortalConfig {
        uint16 x;
        uint16 y;
        uint16 size;
        bool enablePulse;
        uint256 seed;
    }

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

        string memory filters = visualCore.createAllFilters(tokenId);
        string memory textStyle = visualCore.generateTextStyle(colorA, colorB);
        string memory background = visualCore.generateBackground(
            tokenId,
            colorA,
            colorB
        );
        // string memory frames = visualCore.createFrames(colorA, colorB);
        string memory frames = visualCore.createFrames();
        string memory shapes = _generateAllShapes(tokenId);

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
        uint256 tokenId
    ) internal view returns (string memory) {
        QuadrantPlacement.PlacementPlan memory plan = QuadrantPlacement
            .generatePlacementPlan(tokenId);

        string memory red = _generateRedCircles(tokenId, plan);
        string memory pink = _generatePinkSquares(tokenId, plan);
        string memory portals = _generateNeonPortals(tokenId);

        return string.concat(red, pink, portals);
    }

    function _generateNeonPortals(
        uint256 tokenId
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 99999);

        uint16 portalSize = MIN_PORTAL_RADIUS +
            uint16(Random.randInt(ctx) % 601);

        uint8 numPortals = 1 + uint8(Random.randInt(ctx) % 3);

        string memory result = "";

        for (uint8 i = 0; i < numPortals; i++) {
            (uint16 x, uint16 y) = _getSafePortalPosition(ctx, i, numPortals);
            uint256 seed = tokenId + uint256(i);
            bool enablePulse = (seed % 3) == 0;

            uint16 centerX;
            uint16 centerY;

            if (numPortals == 1) {
                centerX = x;
                centerY = y;
            } else if (numPortals == 2) {
                centerX = 620;
                centerY = 720;
            } else {
                centerX = 720;
                centerY = 613;
            }

            string memory portal = neonPortal.createAnimatedNeonPortal(
                x,
                y,
                portalSize,
                seed,
                enablePulse,
                true, // enableMovement
                centerX,
                centerY
            );

            result = string.concat(result, portal);
        }

        return result;
    }

    function _getSafePortalPosition(
        RandomCtx memory ctx,
        uint8 portalIndex,
        uint8 totalPortals
    ) internal pure returns (uint16, uint16) {
        if (totalPortals == 1) {
            // Single portal: random position within safe bounds
            return (
                200 + uint16(Random.randInt(ctx) % 1040),
                200 + uint16(Random.randInt(ctx) % 1040)
            );
        } else if (totalPortals == 2) {
            if (portalIndex == 0) {
                // First portal: left side
                return (
                    200 + uint16(Random.randInt(ctx) % 400),
                    200 + uint16(Random.randInt(ctx) % 1040)
                );
            } else {
                // Second portal: right side (opposite)
                return (
                    840 + uint16(Random.randInt(ctx) % 400),
                    200 + uint16(Random.randInt(ctx) % 1040)
                );
            }
        } else {
            // Three portals: predefined safe positions
            if (portalIndex == 0) {
                return (400, 400); // Top-left area
            } else if (portalIndex == 1) {
                return (1040, 400); // Top-right area
            } else {
                return (720, 1040); // Bottom center
            }
        }
    }

    function _randomPositionInRadius(
        RandomCtx memory ctx,
        uint16 radius
    ) internal pure returns (uint16, uint16) {
        // Generate random angle and distance - but keep it simple
        uint256 angle = Random.randInt(ctx) % 4; // Just 4 directions
        uint256 distance = Random.randInt(ctx) % 300; // Max 300px from center

        uint16 x;
        uint16 y;

        if (angle == 0) {
            // Top-right
            x = CENTER_X + uint16(distance / 2);
            y = CENTER_Y - uint16(distance / 2);
        } else if (angle == 1) {
            // Bottom-right
            x = CENTER_X + uint16(distance / 2);
            y = CENTER_Y + uint16(distance / 2);
        } else if (angle == 2) {
            // Bottom-left
            x = CENTER_X - uint16(distance / 2);
            y = CENTER_Y + uint16(distance / 2);
        } else {
            // Top-left
            x = CENTER_X - uint16(distance / 2);
            y = CENTER_Y - uint16(distance / 2);
        }

        // Ensure bounds are safe
        if (x < 100) x = 100;
        if (x > 1340) x = 1340;
        if (y < 100) y = 100;
        if (y > 1340) y = 1340;

        return (x, y);
    }

    function _getOppositeQuadrantPosition(
        RandomCtx memory ctx,
        uint16 x1,
        uint16 y1
    ) internal pure returns (uint16, uint16) {
        // Determine which quadrant the first portal is in
        bool rightSide = x1 > CENTER_X;
        bool bottomSide = y1 > CENTER_Y;

        // Place second portal in opposite quadrant with safe bounds
        uint16 x2;
        uint16 y2;
        uint256 rand1 = Random.randInt(ctx);
        uint256 rand2 = Random.randInt(ctx);

        // Use safer range calculations to avoid underflow
        uint16 safeRange = 620; // CENTER_X - 100 = 720 - 100 = 620

        if (rightSide && !bottomSide) {
            // First is top-right, place in bottom-left
            x2 = 100 + uint16(rand1 % safeRange);
            y2 = CENTER_Y + uint16(rand2 % safeRange);
        } else if (rightSide && bottomSide) {
            // First is bottom-right, place in top-left
            x2 = 100 + uint16(rand1 % safeRange);
            y2 = 100 + uint16(rand2 % safeRange);
        } else if (!rightSide && bottomSide) {
            // First is bottom-left, place in top-right
            x2 = CENTER_X + uint16(rand1 % safeRange);
            y2 = 100 + uint16(rand2 % safeRange);
        } else {
            // First is top-left, place in bottom-right
            x2 = CENTER_X + uint16(rand1 % safeRange);
            y2 = CENTER_Y + uint16(rand2 % safeRange);
        }

        // Final bounds check
        if (x2 < 100) x2 = 100;
        if (x2 > 1340) x2 = 1340;
        if (y2 < 100) y2 = 100;
        if (y2 > 1340) y2 = 1340;

        return (x2, y2);
    }

    // Remove the trigonometry functions that were causing overflow
    // Simple quadrant-based placement is more gas efficient anyway

    function _generateRedCircles(
        uint256 tokenId,
        QuadrantPlacement.PlacementPlan memory plan
    ) internal view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 12345);
        QuadrantPlacement.ShapeConfig[] memory circles = QuadrantPlacement
            .placeRedCircles(ctx, plan);

        string memory result = "";
        for (uint8 i = 0; i < circles.length; i++) {
            uint8 animationPattern = uint8((tokenId + i) % 3);
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
