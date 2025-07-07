// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AbstractTest} from "./AbstractTest.t.sol";
import {UploadTspansDef} from "../src/UploadTspansDef.sol";
import {OnChainArt} from "../src/OnChainArt.sol";
import {ShapeFactory, IShapeRenderer, CircleRenderer, DiamondRenderer, SquareDiamondRenderer, CrossSquareRenderer} from "../src/ShapeFactory.sol";
import {ASCIIGenerator} from "../src/ASCIIGenerator.sol";
import {NeonEffects} from "../src/NeonEffects.sol";
import {Animations} from "../src/Animations.sol";

contract OnChainArtTest is AbstractTest {
    OnChainArt public renderer;
    UploadTspansDef public uploader;
    ShapeFactory public shapeFactory;
    ASCIIGenerator public asciiGenerator;
    NeonEffects public neonEffects; // ADD THIS
    Animations public animations; // Optional: If you want to test animations

    function setUp() public {
        // 1. Deploy all modules
        asciiGenerator = new ASCIIGenerator();
        neonEffects = new NeonEffects(); // ADD THIS
        animations = new Animations(); // Optional: If you want to test animations
        shapeFactory = new ShapeFactory();

        // 2. Register shape renderers
        CircleRenderer circleRenderer = new CircleRenderer();
        DiamondRenderer diamondRenderer = new DiamondRenderer();
        SquareDiamondRenderer squareDiamondRenderer = new SquareDiamondRenderer();
        CrossSquareRenderer crossSquareRenderer = new CrossSquareRenderer();

        shapeFactory.addShapeRenderer(address(circleRenderer));
        shapeFactory.addShapeRenderer(address(diamondRenderer));
        shapeFactory.addShapeRenderer(address(squareDiamondRenderer));
        shapeFactory.addShapeRenderer(address(crossSquareRenderer));

        // 3. Deploy main contract with all three addresses
        renderer = new OnChainArt(
            address(shapeFactory),
            address(asciiGenerator),
            address(neonEffects), // ADD THIS
            address(animations) // Optional: If you want to test animations
        );

        // 4. Deploy uploader
        UploadTspansDef store = new UploadTspansDef();
        uploader = store;
    }

    function renderContract(
        uint256 id
    ) internal view override returns (string memory) {
        return renderer.renderSVG(id);
    }

    function testSvgRenderer() public view {
        super.testRenderer();
    }

    // Optional: Test individual shape renderers
    function testShapeFactory() public view {
        // Test that all 4 shape types are registered
        require(
            shapeFactory.shapeTypeCount() == 4,
            "Should have 4 shape types"
        );

        // Test individual shape rendering
        IShapeRenderer.ShapeParams memory params = IShapeRenderer.ShapeParams({
            x: 100,
            y: 100,
            color: "#FF0000",
            seed: 12345,
            size: 60
        });

        string memory circle = shapeFactory.renderShape(0, params);
        require(bytes(circle).length > 0, "Circle should render");
    }
}
