// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Random, RandomCtx} from "./utils/Random.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

interface IShapeRenderer {
    struct ShapeParams {
        uint256 x;
        uint256 y;
        string color;
        uint256 seed;
        uint256 size; // for future scaling
    }

    function renderShape(
        ShapeParams memory params
    ) external pure returns (string memory);

    function getShapeId() external pure returns (string memory);
}

contract ShapeFactory {
    mapping(uint256 => address) public shapeRenderers;
    uint256 public shapeTypeCount;

    event ShapeRendererAdded(uint256 indexed shapeType, address renderer);

    function addShapeRenderer(address renderer) external {
        shapeRenderers[shapeTypeCount] = renderer;
        emit ShapeRendererAdded(shapeTypeCount, renderer);
        shapeTypeCount++;
    }

    function renderShape(
        uint256 shapeType,
        IShapeRenderer.ShapeParams memory params
    ) external view returns (string memory) {
        address renderer = shapeRenderers[shapeType];
        require(renderer != address(0), "Shape type not found");
        return IShapeRenderer(renderer).renderShape(params);
    }

    // Adapted from your original _generateOptimizedShapes
    function generateShapes(
        uint256 tokenId,
        uint256 count
    ) external view returns (string memory) {
        RandomCtx memory ctx = Random.initCtx(tokenId + 12345);
        string memory result = "";

        for (uint256 i; i < count; ++i) {
            uint256 shapeType = Random.randInt(ctx) % shapeTypeCount;
            if (shapeTypeCount == 0) break; // Safety check

            IShapeRenderer.ShapeParams memory params = IShapeRenderer
                .ShapeParams({
                    x: 80 + (Random.randInt(ctx) % 1280),
                    y: 80 + (Random.randInt(ctx) % 1280),
                    color: _getLockedShapeColor(shapeType),
                    seed: Random.randInt(ctx),
                    size: 60 // Standard size for now
                });

            result = string(
                abi.encodePacked(result, this.renderShape(shapeType, params))
            );
        }

        return result;
    }

    // Adapted from your original color mapping
    function _getLockedShapeColor(
        uint256 shapeType
    ) internal pure returns (string memory) {
        if (shapeType == 0) return "#FF0000"; // Circle: Red
        if (shapeType == 1) return "#00FFFF"; // Diamond: Cyan
        if (shapeType == 2) return "#00FF00"; // Square+Diamond: Green
        if (shapeType == 3) return "#FF00FF"; // Cross Square: Pink
        return "#FFFF00"; // Default: Yellow for future shapes
    }
}

// CircleRenderer
contract CircleRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<circle cx="',
                    Strings.toString(params.x),
                    '" cy="',
                    Strings.toString(params.y),
                    '" r="60" fill="none" stroke="',
                    params.color,
                    '" stroke-width="4"/>'
                )
            );
    }

    function getShapeId() external pure override returns (string memory) {
        return "circle";
    }
}

// DiamondRenderer - adapted from your buildDiamond
contract DiamondRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        string memory transform = string(
            abi.encodePacked(
                '<g transform="translate(',
                Strings.toString(params.x),
                ",",
                Strings.toString(params.y),
                ") rotate(",
                _intToString(int256((params.seed % 61)) - 30),
                ')">'
            )
        );

        return
            string(
                abi.encodePacked(
                    transform,
                    '<polygon points="0,-25 50,0 0,25 -50,0" fill="none" stroke="',
                    params.color,
                    '" stroke-width="4"/></g>'
                )
            );
    }

    function getShapeId() external pure returns (string memory) {
        return "diamond";
    }

    // Helper function from your original contract
    function _intToString(int256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        bool negative = value < 0;
        if (negative) value = -value;

        uint256 temp = uint256(value);
        uint256 digits;
        uint256 tempValue = temp;

        while (tempValue != 0) {
            digits++;
            tempValue /= 10;
        }

        bytes memory buffer = new bytes(negative ? digits + 1 : digits);
        uint256 index = buffer.length;

        while (temp != 0) {
            index--;
            buffer[index] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }

        if (negative) {
            buffer[0] = "-";
        }

        return string(buffer);
    }
}

// SquareDiamondRenderer - adapted from your buildSquareDiamond
contract SquareDiamondRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        string memory outer = string(
            abi.encodePacked(
                '<g><rect x="',
                Strings.toString(params.x - 30),
                '" y="',
                Strings.toString(params.y - 30),
                '" width="60" height="60" fill="none" stroke="',
                params.color,
                '" stroke-width="4"/>'
            )
        );

        string memory inner = string(
            abi.encodePacked(
                '<g transform="translate(',
                Strings.toString(params.x),
                ",",
                Strings.toString(params.y),
                ') rotate(45)">',
                '<rect x="-18" y="-18" width="36" height="36" fill="none" stroke="',
                params.color,
                '" stroke-width="4"/></g></g>'
            )
        );

        return string(abi.encodePacked(outer, inner));
    }

    function getShapeId() external pure override returns (string memory) {
        return "square_diamond";
    }
}

// CrossSquareRenderer - your updated diagonal cross version
contract CrossSquareRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        string memory square = string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString(params.x - 30),
                '" y="',
                Strings.toString(params.y - 30),
                '" width="60" height="60" fill="none" stroke="',
                params.color,
                '" stroke-width="4"/>'
            )
        );

        string memory diagonals = string(
            abi.encodePacked(
                '<line x1="',
                Strings.toString(params.x - 30),
                '" y1="',
                Strings.toString(params.y - 30),
                '" x2="',
                Strings.toString(params.x + 30),
                '" y2="',
                Strings.toString(params.y + 30),
                '" stroke="',
                params.color,
                '" stroke-width="4"/>',
                '<line x1="',
                Strings.toString(params.x + 30),
                '" y1="',
                Strings.toString(params.y - 30),
                '" x2="',
                Strings.toString(params.x - 30),
                '" y2="',
                Strings.toString(params.y + 30),
                '" stroke="',
                params.color,
                '" stroke-width="4"/>'
            )
        );

        return string(abi.encodePacked("<g>", square, diagonals, "</g>"));
    }

    function getShapeId() external pure override returns (string memory) {
        return "cross_square";
    }
}
