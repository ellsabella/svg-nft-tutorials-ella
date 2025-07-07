// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";

// Quadrant-based placement system - ULTRA SIMPLIFIED
library QuadrantPlacement {
    struct ShapeConfig {
        uint16 x;
        uint16 y;
        uint8 size;
        uint8 quadrant;
        uint8 shapeType;
    }

    struct PlacementPlan {
        uint8 redCircleQuadrant;
        uint8 redCircleCount;
        uint8 secondaryShapeType;
        uint8 secondaryClusterCount;
        uint8 tertiaryCount1;
        uint8 tertiaryCount2;
        uint8 pinkSquareCount;
    }

    function generatePlacementPlan(
        uint256 tokenId
    ) internal pure returns (PlacementPlan memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 777);

        return
            PlacementPlan(
                uint8(Random.randInt(ctx) % 4),
                1 + uint8(Random.randInt(ctx) % 3),
                (Random.randInt(ctx) % 2 == 0) ? 1 : 2,
                8 + uint8(Random.randInt(ctx) % 5),
                3 + uint8(Random.randInt(ctx) % 2),
                3 + uint8(Random.randInt(ctx) % 2),
                1 + uint8(Random.randInt(ctx) % 4)
            );
    }

    function placeRedCircles(
        RandomCtx memory ctx,
        PlacementPlan memory plan
    ) internal pure returns (ShapeConfig[] memory) {
        ShapeConfig[] memory circles = new ShapeConfig[](plan.redCircleCount);

        for (uint8 i = 0; i < plan.redCircleCount; i++) {
            circles[i] = _createRedCircle(ctx, plan.redCircleQuadrant);
        }

        return circles;
    }

    function placeSecondaryCluster(
        RandomCtx memory ctx,
        PlacementPlan memory plan
    ) internal pure returns (ShapeConfig[] memory) {
        ShapeConfig[] memory cluster = new ShapeConfig[](
            plan.secondaryClusterCount
        );
        uint8 oppositeQuad = _getOpposite(plan.redCircleQuadrant);

        for (uint8 i = 0; i < plan.secondaryClusterCount; i++) {
            cluster[i] = _createSecondaryShape(
                ctx,
                oppositeQuad,
                plan.secondaryShapeType
            );
        }

        return cluster;
    }

    function placeTertiaryClusters(
        RandomCtx memory ctx,
        PlacementPlan memory plan
    ) internal pure returns (ShapeConfig[] memory) {
        uint8 totalCount = plan.tertiaryCount1 + plan.tertiaryCount2;
        ShapeConfig[] memory tertiary = new ShapeConfig[](totalCount);
        uint8 tertiaryType = (plan.secondaryShapeType == 1) ? 2 : 1;

        (uint8 empty1, uint8 empty2) = _getEmptyQuadrants(
            plan.redCircleQuadrant
        );

        uint8 index = 0;

        // Fill first quadrant
        for (uint8 i = 0; i < plan.tertiaryCount1; i++) {
            tertiary[index] = _createTertiaryShape(ctx, empty1, tertiaryType);
            index++;
        }

        // Fill second quadrant
        for (uint8 i = 0; i < plan.tertiaryCount2; i++) {
            tertiary[index] = _createTertiaryShape(ctx, empty2, tertiaryType);
            index++;
        }

        return tertiary;
    }

    function placePinkSquares(
        RandomCtx memory ctx,
        PlacementPlan memory plan
    ) internal pure returns (ShapeConfig[] memory) {
        ShapeConfig[] memory pinks = new ShapeConfig[](plan.pinkSquareCount);

        for (uint8 i = 0; i < plan.pinkSquareCount; i++) {
            uint8 quadrant = _selectPinkQuadrant(ctx, plan.redCircleQuadrant);
            pinks[i] = _createPinkSquare(ctx, quadrant);
        }

        return pinks;
    }

    // ULTRA SIMPLIFIED SHAPE CREATORS

    // 1. RED CIRCLES - In _createRedCircle function:
    function _createRedCircle(
        RandomCtx memory ctx,
        uint8 quadrant
    ) private pure returns (ShapeConfig memory) {
        uint256 r1 = Random.randInt(ctx);
        uint256 r2 = Random.randInt(ctx);
        uint256 r3 = Random.randInt(ctx);

        return
            ShapeConfig({
                x: _getQuadX(quadrant) + uint16(r1 % 480),
                y: _getQuadY(quadrant) + uint16(r2 % 480),
                size: 65 + uint8(r3 % 40), // CHANGED: was 50 + (r3 % 31), now 65 + (r3 % 40) = 65-104 (was 50-80)
                quadrant: quadrant,
                shapeType: 0
            });
    }

    // 2. SECONDARY SHAPES (diamonds/squares) - In _createSecondaryShape function:
    function _createSecondaryShape(
        RandomCtx memory ctx,
        uint8 quadrant,
        uint8 shapeType
    ) private pure returns (ShapeConfig memory) {
        uint256 r1 = Random.randInt(ctx);
        uint256 r2 = Random.randInt(ctx);
        uint256 r3 = Random.randInt(ctx);

        return
            ShapeConfig({
                x: _getQuadX(quadrant) + uint16(r1 % 500),
                y: _getQuadY(quadrant) + uint16(r2 % 500),
                size: 39 + uint8(r3 % 40), // CHANGED: was 30 + (r3 % 31), now 39 + (r3 % 40) = 39-78 (was 30-60)
                quadrant: quadrant,
                shapeType: shapeType
            });
    }

    // 3. TERTIARY SHAPES - In _createTertiaryShape function:
    function _createTertiaryShape(
        RandomCtx memory ctx,
        uint8 quadrant,
        uint8 shapeType
    ) private pure returns (ShapeConfig memory) {
        uint256 r1 = Random.randInt(ctx);
        uint256 r2 = Random.randInt(ctx);
        uint256 r3 = Random.randInt(ctx);

        return
            ShapeConfig({
                x: _getQuadX(quadrant) + uint16(r1 % 520),
                y: _getQuadY(quadrant) + uint16(r2 % 520),
                size: 46 + uint8(r3 % 34), // CHANGED: was 35 + (r3 % 26), now 46 + (r3 % 34) = 46-79 (was 35-60)
                quadrant: quadrant,
                shapeType: shapeType
            });
    }

    // 4. PINK SQUARES - In _createPinkSquare function:
    function _createPinkSquare(
        RandomCtx memory ctx,
        uint8 quadrant
    ) private pure returns (ShapeConfig memory) {
        uint256 r1 = Random.randInt(ctx);
        uint256 r2 = Random.randInt(ctx);
        uint256 r3 = Random.randInt(ctx);

        return
            ShapeConfig({
                x: _getQuadX(quadrant) + uint16(r1 % 500),
                y: _getQuadY(quadrant) + uint16(r2 % 500),
                size: 52 + uint8(r3 % 27), // CHANGED: was 40 + (r3 % 21), now 52 + (r3 % 27) = 52-78 (was 40-60)
                quadrant: quadrant,
                shapeType: 3
            });
    }

    // MINIMAL UTILITY FUNCTIONS
    function _getQuadX(uint8 quadrant) private pure returns (uint16) {
        return (quadrant == 1 || quadrant == 3) ? 720 : 120;
    }

    function _getQuadY(uint8 quadrant) private pure returns (uint16) {
        return (quadrant == 2 || quadrant == 3) ? 720 : 120;
    }

    function _getOpposite(uint8 quadrant) private pure returns (uint8) {
        if (quadrant == 0) return 3;
        if (quadrant == 1) return 2;
        if (quadrant == 2) return 1;
        return 0;
    }

    function _getEmptyQuadrants(
        uint8 redQuad
    ) private pure returns (uint8, uint8) {
        if (redQuad == 0) return (1, 2);
        if (redQuad == 1) return (0, 3);
        if (redQuad == 2) return (0, 3);
        return (1, 2);
    }

    function _selectPinkQuadrant(
        RandomCtx memory ctx,
        uint8 redQuad
    ) private pure returns (uint8) {
        uint256 choice = Random.randInt(ctx) % 3;
        uint8 opposite = _getOpposite(redQuad);
        (uint8 empty1, uint8 empty2) = _getEmptyQuadrants(redQuad);

        if (choice == 0) return opposite;
        if (choice == 1) return empty1;
        return empty2;
    }
}
