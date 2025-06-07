// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StdAssertions } from "forge-std/src/StdAssertions.sol";

import { BaseTest } from "src/tests/BaseTest.sol";
import { SablierComptroller } from "src/SablierComptroller.sol";

contract ChainlinkOracle_Fork_Test is BaseTest, StdAssertions {
    SablierComptroller internal comptroller;

    /// @notice A modifier that runs the forked test for a given chain
    modifier initForkTest(string memory chainName) {
        // Fork chain on the latest block number.
        vm.createSelectFork({ urlOrAlias: chainName });

        // Deploy the Merkle Instant factory and create a new campaign.
        comptroller = new SablierComptroller(
            makeAddr("admin"), initialMinFeeUSD(), initialMinFeeUSD(), initialMinFeeUSD(), chainlinkOracle()
        );

        // Assert that the Chainlink returns a non-zero price by checking the value of min fee in wei.
        assertLt(0, comptroller.calculateMinFeeWeiAirdrops(), "min fee wei");
        assertLt(0, comptroller.calculateMinFeeWeiFlow(), "min fee wei");
        assertLt(0, comptroller.calculateMinFeeWeiLockup(), "min fee wei");

        _;
    }

    // function testFork_ChainlinkOracle_Mainnet() external initForkTest("mainnet") { }

    // function testFork_ChainlinkOracle_Arbitrum() external initForkTest("arbitrum") { }

    // function testFork_ChainlinkOracle_Avalanche() external initForkTest("avalanche") { }

    // function testFork_ChainlinkOracle_Base() external initForkTest("base") { }

    // function testFork_ChainlinkOracle_BNB() external initForkTest("bnb") { }

    // function testFork_ChainlinkOracle_Gnosis() external initForkTest("gnosis") { }

    // function testFork_ChainlinkOracle_Linea() external initForkTest("linea") { }

    // function testFork_ChainlinkOracle_Optimism() external initForkTest("optimism") { }

    // function testFork_ChainlinkOracle_Polygon() external initForkTest("polygon") { }

    // function testFork_ChainlinkOracle_Scroll() external initForkTest("scroll") { }

    /*//////////////////////////////////////////////////////////////////////////
                                      HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the Chainlink oracle for the supported chains. These addresses can be verified on
    /// https://docs.chain.link/data-feeds/price-feeds/addresses.
    /// @dev If the chain does not have a Chainlink oracle, return 0.
    // solhint-disable-next-line code-complexity
    function chainlinkOracle() public view returns (address addr) {
        uint256 chainId = block.chainid;

        // Ethereum Mainnet
        if (chainId == 1) return 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        // Arbitrum One
        if (chainId == 42_161) return 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
        // Avalanche
        if (chainId == 43_114) return 0x0A77230d17318075983913bC2145DB16C7366156;
        // Base
        if (chainId == 8453) return 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
        // BNB Smart Chain
        if (chainId == 56) return 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
        // Gnosis Chain
        if (chainId == 100) return 0x678df3415fc31947dA4324eC63212874be5a82f8;
        // Linea
        if (chainId == 59_144) return 0x3c6Cd9Cc7c7a4c2Cf5a82734CD249D7D593354dA;
        // Optimism
        if (chainId == 10) return 0x13e3Ee699D1909E989722E753853AE30b17e08c5;
        // Polygon
        if (chainId == 137) return 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
        // Scroll
        if (chainId == 534_352) return 0x6bF14CB0A831078629D993FDeBcB182b21A8774C;

        // Return address zero for unsupported chain.
        return address(0);
    }

    /// @notice Returns the initial min USD fee as $1. If the chain does not have Chainlink, return 0.
    function initialMinFeeUSD() public view returns (uint256) {
        if (chainlinkOracle() != address(0)) {
            return 1e8;
        }
        return 0;
    }
}
