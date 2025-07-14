// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AbstractTest} from "./AbstractTest.t.sol";
import {OnChainArt} from "../src/OnChainArt.sol";
import {VisualCore} from "../src/VisualCore.sol";
import {RedCircles} from "../src/RedCircles.sol";
import {BlueDiamonds} from "../src/BlueDiamonds.sol";
import {GreenSquares} from "../src/GreenSquares.sol";
import {BasicShapes} from "../src/BasicShapes.sol";
import {NeonPortal} from "../src/NeonPortal.sol";

contract OnChainArtTest is AbstractTest {
    OnChainArt public renderer;
    VisualCore public visualCore;
    RedCircles public redCircles;
    BlueDiamonds public blueDiamonds;
    GreenSquares public greenSquares;
    BasicShapes public basicShapes;
    NeonPortal public neonPortal;

    function setUp() public {
        // 1. Deploy all specialized contracts
        visualCore = new VisualCore();
        redCircles = new RedCircles();
        blueDiamonds = new BlueDiamonds();
        greenSquares = new GreenSquares();
        basicShapes = new BasicShapes();
        neonPortal = new NeonPortal(address(visualCore));

        // 2. Deploy main orchestrator with all contract addresses
        renderer = new OnChainArt(
            address(visualCore),
            address(redCircles),
            address(blueDiamonds),
            address(greenSquares),
            address(basicShapes),
            address(neonPortal)
        );
    }

    function renderContract(
        uint256 id
    ) internal view override returns (string memory) {
        return renderer.renderSVG(id);
    }

    function testSvgRenderer() public view {
        super.testRenderer();
    }

    // Optional: Test individual contracts
    function testVisualCore() public view {
        string memory filters = visualCore.createAllFilters(123);
        require(bytes(filters).length > 0, "Filters should render");

        string memory background = visualCore.generateBackground(
            12345,
            "#FF0000"
        );
        require(bytes(background).length > 0, "Background should render");

        string memory frames = visualCore.createFrames("#FF0000", "#00FF00");
        require(bytes(frames).length > 0, "Frames should render");

        string memory textStyle = visualCore.generateTextStyle(
            "#FF0000",
            "#00FF00"
        );
        require(bytes(textStyle).length > 0, "Text style should render");
    }

    function testRedCircles() public view {
        string memory circle = redCircles.createAnimatedCircle(
            100,
            100,
            60,
            12345,
            0 // linear animation
        );
        require(bytes(circle).length > 0, "Red circle should render");

        string memory orbitCircle = redCircles.createAnimatedCircle(
            200,
            200,
            60,
            12345,
            1 // orbit animation
        );
        require(bytes(orbitCircle).length > 0, "Orbit circle should render");

        string memory pulseCircle = redCircles.createAnimatedCircle(
            300,
            300,
            60,
            12345,
            2 // pulse animation
        );
        require(bytes(pulseCircle).length > 0, "Pulse circle should render");
    }

    function testBlueDiamonds() public view {
        string memory diamond = blueDiamonds.createAnimatedDiamond(
            100,
            100,
            50,
            12345,
            false // no pulse
        );
        require(bytes(diamond).length > 0, "Blue diamond should render");

        string memory pulsingDiamond = blueDiamonds.createAnimatedDiamond(
            200,
            200,
            50,
            12345,
            true // with pulse
        );
        require(
            bytes(pulsingDiamond).length > 0,
            "Pulsing diamond should render"
        );
    }

    function testGreenSquares() public view {
        string memory square = greenSquares.createAnimatedSquare(
            100,
            100,
            50,
            12345,
            false // no pulse
        );
        require(bytes(square).length > 0, "Green square should render");

        string memory pulsingSquare = greenSquares.createAnimatedSquare(
            200,
            200,
            50,
            12345,
            true // with pulse
        );
        require(
            bytes(pulsingSquare).length > 0,
            "Pulsing square should render"
        );
    }

    function testBasicShapes() public view {
        string memory crossSquare = basicShapes.createCrossSquare(
            100,
            100,
            50,
            12345
        );
        require(bytes(crossSquare).length > 0, "Cross square should render");
    }

    function testNeonPortal() public view {
        string memory portal = neonPortal.createNeonPortal(
            720,
            720,
            80,
            12345,
            false
        );
        require(bytes(portal).length > 0, "Neon portal should render");

        string memory pulsingPortal = neonPortal.createNeonPortal(
            720,
            720,
            80,
            12345,
            true
        );
        require(
            bytes(pulsingPortal).length > 0,
            "Pulsing portal should render"
        );
    }

    function testArchitecture() public view {
        // Test that all contracts are properly connected
        require(
            address(renderer.visualCore()) == address(visualCore),
            "VisualCore not connected"
        );
        require(
            address(renderer.redCircles()) == address(redCircles),
            "RedCircles not connected"
        );
        require(
            address(renderer.blueDiamonds()) == address(blueDiamonds),
            "BlueDiamonds not connected"
        );
        require(
            address(renderer.greenSquares()) == address(greenSquares),
            "GreenSquares not connected"
        );
        require(
            address(renderer.basicShapes()) == address(basicShapes),
            "BasicShapes not connected"
        );
        require(
            address(renderer.neonPortal()) == address(neonPortal), // ADD THIS LINE
            "NeonPortal not connected"
        );
    }
}
