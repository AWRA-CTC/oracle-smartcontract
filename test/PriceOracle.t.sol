// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PriceOracle} from "../src/PriceOracle.sol";

contract PriceOracleTest is Test {
    PriceOracle public oracle;
    address public admin;
    address public user;
    address public asset;

    uint256 public constant MAX_DEVIATION = 500; // 5%
    uint256 public constant MIN_UPDATE_INTERVAL = 3600; // 1 hour

    function setUp() public {
        admin = makeAddr("admin");
        user = makeAddr("user");
        asset = makeAddr("asset");

        vm.prank(admin);
        oracle = new PriceOracle(admin, MAX_DEVIATION, MIN_UPDATE_INTERVAL);
    }

    function test_InitialState() public {
        assertEq(oracle.admin(), admin);
        assertEq(oracle.maxDeviation(), MAX_DEVIATION);
        assertEq(oracle.minUpdateInterval(), MIN_UPDATE_INTERVAL);
    }

    function test_UpdatePrice_Success() public {
        uint256 price = 1000e8;

        vm.prank(admin);
        oracle.updatePrice(asset, price);

        assertEq(oracle.getPrice(asset), price);
        assertEq(oracle.getLastUpdated(asset), block.timestamp);
    }

    function test_RevertWhen_CallerIsNotAdmin() public {
        uint256 price = 1000e8;

        vm.prank(user);
        vm.expectRevert(PriceOracle.NotAdmin.selector);
        oracle.updatePrice(asset, price);
    }

    function test_RevertWhen_PriceIsZero() public {
        vm.prank(admin);
        vm.expectRevert(PriceOracle.InvalidPrice.selector);
        oracle.updatePrice(asset, 0);
    }

    function test_RevertWhen_UpdateTooSoon() public {
        uint256 price1 = 1000e8;
        uint256 price2 = 1010e8;

        vm.startPrank(admin);
        oracle.updatePrice(asset, price1);

        // Try to update immediately
        vm.expectRevert(PriceOracle.UpdateTooSoon.selector);
        oracle.updatePrice(asset, price2);
        
        // Advance time just before interval
        vm.warp(block.timestamp + MIN_UPDATE_INTERVAL - 1);
        vm.expectRevert(PriceOracle.UpdateTooSoon.selector);
        oracle.updatePrice(asset, price2);

        // Advance time to allow update
        vm.warp(block.timestamp + 1);
        oracle.updatePrice(asset, price2);
        
        vm.stopPrank();
    }

    function test_RevertWhen_DeviationTooHigh() public {
        uint256 price1 = 1000e8;
        // 5% of 1000 is 50. So 1050 is ok, 1051 is too high?
        // 1050 - 1000 = 50. 50 * 10000 / 1000 = 500000 / 1000 = 500. Matches max.
        // 1051 - 1000 = 51. 51 * 10000 / 1000 = 510000 / 1000 = 510. Exceeds max.
        
        uint256 validPrice = 1050e8;
        uint256 invalidPrice = 1051e8;

        vm.startPrank(admin);
        oracle.updatePrice(asset, price1);

        // Need to wait for interval
        vm.warp(block.timestamp + MIN_UPDATE_INTERVAL);

        // Check valid deviation (exact boundary)
        oracle.updatePrice(asset, validPrice);
        
        // Wait again
        vm.warp(block.timestamp + MIN_UPDATE_INTERVAL);

        // Check invalid deviation
        // Current price is now 1050. 
        // Let's reset to 1000 for easier calculation, or just calculate based on 1050.
        // 5% of 1050 is 52.5. 
        // Let's start fresh with a new asset to match the simple math
        address asset2 = makeAddr("asset2");
        oracle.updatePrice(asset2, 1000e8);
        vm.warp(block.timestamp + MIN_UPDATE_INTERVAL);

        vm.expectRevert(PriceOracle.PriceDeviationTooHigh.selector);
        oracle.updatePrice(asset2, invalidPrice); // 1051 is > 5% of 1000
        
        vm.stopPrank();
    }
}
