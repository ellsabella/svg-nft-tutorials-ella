// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";

// Simplified collision detection using coordinate lists instead of grid arrays
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

    // Simple collision tracking with coordinate arrays (max 20 squares total)
    struct PlacedSquares {
        uint16[20] x;
        uint16[20] y;
        uint8[20] size;
        uint8 count;
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
    ) internal pure returns (ShapeConfig[] memory, PlacedSquares memory) {
        uint8 totalCount = plan.tertiaryCount1 + plan.tertiaryCount2;
        ShapeConfig[] memory tertiary = new ShapeConfig[](totalCount);
        uint8 tertiaryType = (plan.secondaryShapeType == 1) ? 2 : 1;

        // Initialize collision tracking
        PlacedSquares memory placed;

        (uint8 empty1, uint8 empty2) = _getEmptyQuadrants(
            plan.redCircleQuadrant
        );

        uint8 index = 0;

        // Fill first quadrant (Green squares with collision detection)
        for (uint8 i = 0; i < plan.tertiaryCount1; i++) {
            ShapeConfig memory shape = _createTertiaryShapeWithCollision(
                ctx,
                empty1,
                tertiaryType,
                placed
            );
            if (shape.size > 0) {
                // Only add if placement succeeded
                tertiary[index] = shape;
                index++;
            }
        }

        // Fill second quadrant (Green squares with collision detection)
        for (uint8 i = 0; i < plan.tertiaryCount2; i++) {
            ShapeConfig memory shape = _createTertiaryShapeWithCollision(
                ctx,
                empty2,
                tertiaryType,
                placed
            );
            if (shape.size > 0) {
                // Only add if placement succeeded
                tertiary[index] = shape;
                index++;
            }
        }

        // Resize array to actual placed count
        ShapeConfig[] memory result = new ShapeConfig[](index);
        for (uint8 i = 0; i < index; i++) {
            result[i] = tertiary[i];
        }

        return (result, placed); // Return both shapes and collision state
    }

    function placePinkSquares(
        RandomCtx memory ctx,
        PlacementPlan memory plan,
        PlacedSquares memory existingPlaced // Accept existing collision state
    ) internal pure returns (ShapeConfig[] memory) {
        ShapeConfig[] memory pinks = new ShapeConfig[](plan.pinkSquareCount);

        uint8 actualCount = 0;
        for (uint8 i = 0; i < plan.pinkSquareCount; i++) {
            uint8 quadrant = _selectPinkQuadrant(ctx, plan.redCircleQuadrant);
            ShapeConfig memory shape = _createPinkSquareWithCollision(
                ctx,
                quadrant,
                existingPlaced
            );
            if (shape.size > 0) {
                // Only add if placement succeeded
                pinks[actualCount] = shape;
                actualCount++;
            }
        }

        // Resize array to actual placed count
        ShapeConfig[] memory result = new ShapeConfig[](actualCount);
        for (uint8 i = 0; i < actualCount; i++) {
            result[i] = pinks[i];
        }

        return result;
    }

    // Overloaded version: placePinkSquares without existing collision state (creates empty state)
    function placePinkSquares(
        RandomCtx memory ctx,
        PlacementPlan memory plan
    ) internal pure returns (ShapeConfig[] memory) {
        PlacedSquares memory emptyPlaced; // Start with empty collision state
        return placePinkSquares(ctx, plan, emptyPlaced);
    }

    // COLLISION-AWARE SHAPE CREATORS

    function _createTertiaryShapeWithCollision(
        RandomCtx memory ctx,
        uint8 quadrant,
        uint8 shapeType,
        PlacedSquares memory placed
    ) private pure returns (ShapeConfig memory) {
        uint8 attempts = 10; // Try up to 10 positions

        for (uint8 attempt = 0; attempt < attempts; attempt++) {
            uint256 r1 = Random.randInt(ctx);
            uint256 r2 = Random.randInt(ctx);

            uint16 x = _getQuadX(quadrant) + uint16(r1 % 520);
            uint16 y = _getQuadY(quadrant) + uint16(r2 % 520);
            uint8 size = 90; // Fixed size for green squares

            if (_canPlaceSquare(placed, x, y, size)) {
                _addPlacedSquare(placed, x, y, size);
                return
                    ShapeConfig({
                        x: x,
                        y: y,
                        size: size,
                        quadrant: quadrant,
                        shapeType: shapeType
                    });
            }
        }

        // Return empty config if couldn't place
        return ShapeConfig({x: 0, y: 0, size: 0, quadrant: 0, shapeType: 0});
    }

    function _createPinkSquareWithCollision(
        RandomCtx memory ctx,
        uint8 quadrant,
        PlacedSquares memory placed
    ) private pure returns (ShapeConfig memory) {
        uint8 attempts = 10; // Try up to 10 positions

        for (uint8 attempt = 0; attempt < attempts; attempt++) {
            uint256 r1 = Random.randInt(ctx);
            uint256 r2 = Random.randInt(ctx);

            uint16 x = _getQuadX(quadrant) + uint16(r1 % 500);
            uint16 y = _getQuadY(quadrant) + uint16(r2 % 500);
            uint8 size = 60; // Fixed size for pink squares

            if (_canPlaceSquare(placed, x, y, size)) {
                _addPlacedSquare(placed, x, y, size);
                return
                    ShapeConfig({
                        x: x,
                        y: y,
                        size: size,
                        quadrant: quadrant,
                        shapeType: 3
                    });
            }
        }

        // Return empty config if couldn't place
        return ShapeConfig({x: 0, y: 0, size: 0, quadrant: 0, shapeType: 0});
    }

    // SIMPLE COLLISION DETECTION

    function _canPlaceSquare(
        PlacedSquares memory placed,
        uint16 newX,
        uint16 newY,
        uint8 newSize
    ) private pure returns (bool) {
        uint16 halfNew = newSize / 2;

        for (uint8 i = 0; i < placed.count; i++) {
            uint16 existingX = placed.x[i];
            uint16 existingY = placed.y[i];
            uint8 existingSize = placed.size[i];
            uint16 halfExisting = existingSize / 2;

            // Check if rectangles overlap (center-based collision)
            uint16 minDistance = halfNew + halfExisting;

            // Use safe distance comparison to avoid underflow
            bool xOverlap = (newX > existingX)
                ? (newX - existingX < minDistance)
                : (existingX - newX < minDistance);

            bool yOverlap = (newY > existingY)
                ? (newY - existingY < minDistance)
                : (existingY - newY < minDistance);

            if (xOverlap && yOverlap) {
                return false; // Collision detected
            }
        }

        return true; // No collision
    }

    function _addPlacedSquare(
        PlacedSquares memory placed,
        uint16 x,
        uint16 y,
        uint8 size
    ) private pure {
        if (placed.count < 20) {
            // Safety check
            placed.x[placed.count] = x;
            placed.y[placed.count] = y;
            placed.size[placed.count] = size;
            placed.count++;
        }
    }

    // ORIGINAL SHAPE CREATORS (unchanged)

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
                size: 65 + uint8(r3 % 40), // 65-104
                quadrant: quadrant,
                shapeType: 0
            });
    }

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
                size: 39 + uint8(r3 % 40), // 39-78
                quadrant: quadrant,
                shapeType: shapeType
            });
    }

    // UTILITY FUNCTIONS (unchanged)
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
