# Price Oracle Smart Contract

This repository contains a robust, Foundry-based Price Oracle smart contract designed to provide secure and reliable asset price feeds on-chain.

## Overview

The `PriceOracle` contract allows a designated **admin** to update asset prices while enforcing strict security constraints to prevent manipulation and ensure data integrity.

### Key Features

- **Admin Access Control**: Only the designated admin address can update prices.
- **Price Deviation Checks**: Updates are rejected if the new price deviates from the old price by more than a configured percentage (`maxDeviation`). This protects against flash crashes or fat-finger errors.
- **Minimum Update Interval**: Enforces a minimum time delay (`minUpdateInterval`) between price updates to prevent spamming or unnecessary volatility.
- **Historical Tracking**: Stores the timestamp of the last update for each asset.

## Contracts

### `PriceOracle.sol`
The core contract implementation.
- **Constructor Parameters**:
    - `_admin`: The address allowed to update prices.
    - `_maxDeviation`: Maximum allowed price change in Basis Points (BPS). E.g., `500` = 5%.
    - `_minUpdateInterval`: Minimum time (in seconds) between updates.

### `IPriceOracle.sol`
The interface defining the read-only functions:
- `getPrice(address asset)`: Returns the current price (e.g., scaled to 8 decimals).
- `getLastUpdated(address asset)`: Returns the timestamp of the last update.

## Getting Started

### Prerequisites
- [Foundry](https://getfoundry.sh/) must be installed.

### Installation

1.  Clone the repository:
    ```bash
    git clone <repo-url>
    cd oracle-smartcontract
    ```
2.  Install dependencies:
    ```bash
    forge install
    ```

### Build

Compile the smart contracts:

```bash
forge build
```

### Test

Run the comprehensive test suite:

```bash
forge test
```

For detailed traces:
```bash
forge test -vvv
```

### Deployment

To deploy the oracle, use the provided script. You can set the `PRIVATE_KEY` environment variable or use the default Foundry sender for local testing.

```bash
forge script script/DeployPriceOracle.s.sol --broadcast
```

## Security Mechanisms

1.  **Deviation Guard**:
    ```solidity
    if (deviationBps > maxDeviation) revert PriceDeviationTooHigh();
    ```
    Ensures integrity by blocking extreme price swings in a single update.

2.  **Throttling**:
    ```solidity
    if (block.timestamp < lastTime + minUpdateInterval) revert UpdateTooSoon();
    ```
    Prevents rapid-fire updates.

## License
MIT
