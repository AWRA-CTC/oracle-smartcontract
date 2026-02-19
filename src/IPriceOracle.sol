// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceOracle {
    /// @notice Returns the latest price for an asset
    /// @param asset The token address (or identifier)

    function getPrice(address asset) external view returns (uint256);

    /// @notice Returns the number of decimals for the price of an asset
    function getDecimals(address asset) external view returns (uint8);

    /// @notice Returns last update timestamp for an asset
    function getLastUpdated(address asset) external view returns (uint256);
}
