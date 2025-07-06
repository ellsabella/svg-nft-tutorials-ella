// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {AbstractTest} from "./AbstractTest.t.sol";
import {BasicGHZRenderer} from "../src/BasicGHZRenderer.sol";

/**
 * @author Eto Vass
 */
contract BasicGHZRendererTest is AbstractTest {
    BasicGHZRenderer public renderer;

    function setUp() public {
        renderer = new BasicGHZRenderer();
    }

    function renderContract(
        uint tokenId
    ) internal view override returns (string memory) {
        return renderer.renderSVG(tokenId);
    }

    function testSvgRenderer() public view {
        super.testRenderer();
    }
}
