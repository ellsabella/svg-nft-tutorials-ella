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
        uint256 size; // for dynamic scaling
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
}

// CircleRenderer - Simplified to avoid stack depth
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
                    '" r="',
                    Strings.toString(params.size),
                    '" fill="none" stroke="',
                    params.color,
                    '" stroke-width="',
                    Strings.toString(_getStroke(params.size)),
                    '"/>'
                )
            );
    }

    function _getStroke(uint256 size) private pure returns (uint256) {
        uint256 stroke = (size * 8) / 80;
        return stroke < 3 ? 3 : (stroke > 8 ? 8 : stroke);
    }

    function getShapeId() external pure override returns (string memory) {
        return "circle";
    }
}

// DiamondRenderer - Simplified
contract DiamondRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<g transform="translate(',
                    Strings.toString(params.x),
                    ",",
                    Strings.toString(params.y),
                    ") rotate(",
                    _getRotation(params.seed),
                    ')">',
                    '<polygon points="0,-',
                    Strings.toString(params.size / 4),
                    " ",
                    Strings.toString(params.size / 2),
                    ",0 0,",
                    Strings.toString(params.size / 4),
                    " -",
                    Strings.toString(params.size / 2),
                    ',0" fill="none" stroke="',
                    params.color,
                    '" stroke-width="',
                    Strings.toString(_getStroke(params.size)),
                    '"/></g>'
                )
            );
    }

    function _getStroke(uint256 size) private pure returns (uint256) {
        uint256 stroke = (size * 4) / 60;
        return stroke < 2 ? 2 : (stroke > 6 ? 6 : stroke);
    }

    function _getRotation(uint256 seed) private pure returns (string memory) {
        int256 rotation = int256((seed % 61)) - 30;
        return _intToString(rotation);
    }

    function _intToString(int256 value) private pure returns (string memory) {
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

        if (negative) buffer[0] = "-";
        return string(buffer);
    }

    function getShapeId() external pure returns (string memory) {
        return "diamond";
    }
}

// SquareDiamondRenderer - Simplified to reduce variables
contract SquareDiamondRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        // Calculate once, use immediately
        return
            string(
                abi.encodePacked(
                    '<g><rect x="',
                    Strings.toString(params.x - params.size / 2),
                    '" y="',
                    Strings.toString(params.y - params.size / 2),
                    '" width="',
                    Strings.toString(params.size),
                    '" height="',
                    Strings.toString(params.size),
                    '" fill="none" stroke="',
                    params.color,
                    '" stroke-width="',
                    Strings.toString(_getStroke(params.size)),
                    '"/>',
                    _getInnerDiamond(params),
                    "</g>"
                )
            );
    }

    function _getInnerDiamond(
        ShapeParams memory params
    ) private pure returns (string memory) {
        uint256 innerSize = (params.size * 2) / 3;
        return
            string(
                abi.encodePacked(
                    '<g transform="translate(',
                    Strings.toString(params.x),
                    ",",
                    Strings.toString(params.y),
                    ') rotate(45)">',
                    '<rect x="-',
                    Strings.toString(innerSize / 2),
                    '" y="-',
                    Strings.toString(innerSize / 2),
                    '" width="',
                    Strings.toString(innerSize),
                    '" height="',
                    Strings.toString(innerSize),
                    '" fill="none" stroke="',
                    params.color,
                    '" stroke-width="',
                    Strings.toString(_getStroke(params.size)),
                    '"/></g>'
                )
            );
    }

    function _getStroke(uint256 size) private pure returns (uint256) {
        uint256 stroke = (size * 4) / 60;
        return stroke < 2 ? 2 : (stroke > 6 ? 6 : stroke);
    }

    function getShapeId() external pure override returns (string memory) {
        return "square_diamond";
    }
}

// CrossSquareRenderer - Most simplified to avoid stack depth
contract CrossSquareRenderer is IShapeRenderer {
    function renderShape(
        ShapeParams memory params
    ) external pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<g>",
                    _getSquare(params),
                    _getDiagonals(params),
                    "</g>"
                )
            );
    }

    function _getSquare(
        ShapeParams memory params
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect x="',
                    Strings.toString(params.x - params.size / 2),
                    '" y="',
                    Strings.toString(params.y - params.size / 2),
                    '" width="',
                    Strings.toString(params.size),
                    '" height="',
                    Strings.toString(params.size),
                    '" fill="none" stroke="',
                    params.color,
                    '" stroke-width="',
                    Strings.toString(_getStroke(params.size)),
                    '"/>'
                )
            );
    }

    function _getDiagonals(
        ShapeParams memory params
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(_getDiagonal1(params), _getDiagonal2(params))
            );
    }

    function _getDiagonal1(
        ShapeParams memory params
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<line x1="',
                    Strings.toString(params.x - params.size / 2),
                    '" y1="',
                    Strings.toString(params.y - params.size / 2),
                    '" x2="',
                    Strings.toString(params.x + params.size / 2),
                    '" y2="',
                    Strings.toString(params.y + params.size / 2),
                    '" stroke="',
                    params.color,
                    '" stroke-width="4"/>'
                )
            );
    }

    function _getDiagonal2(
        ShapeParams memory params
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<line x1="',
                    Strings.toString(params.x + params.size / 2),
                    '" y1="',
                    Strings.toString(params.y - params.size / 2),
                    '" x2="',
                    Strings.toString(params.x - params.size / 2),
                    '" y2="',
                    Strings.toString(params.y + params.size / 2),
                    '" stroke="',
                    params.color,
                    '" stroke-width="4"/>'
                )
            );
    }

    function _getStroke(uint256 size) private pure returns (uint256) {
        uint256 stroke = (size * 4) / 60;
        return stroke < 2 ? 2 : (stroke > 6 ? 6 : stroke);
    }

    function getShapeId() external pure override returns (string memory) {
        return "cross_square";
    }
}
