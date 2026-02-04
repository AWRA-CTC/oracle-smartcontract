// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PriceOracle} from "../src/PriceOracle.sol";

contract DeployPriceOracle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(0));
        
        // If no private key is provided (local test), use a dummy address or default sender
        // For actual deployment, startBroadcast(deployerPrivateKey) would be used.
        // For this script, we'll just use startBroadcast() which uses the default foundry sender.
        
        vm.startBroadcast();

        // Configuration
        address admin = msg.sender;
        uint256 maxDeviation = 500; // 5%
        uint256 minUpdateInterval = 3600; // 1 hour

        new PriceOracle(admin, maxDeviation, minUpdateInterval);

        vm.stopBroadcast();
    }
}
