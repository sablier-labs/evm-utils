// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { BaseTest } from "src/tests/BaseTest.sol";
import { BaseScript } from "src/tests/BaseScript.sol";
import { SablierComptroller } from "src/SablierComptroller.sol";

contract BaseScriptMock is BaseScript { }

// TODO: uncomment this later.
contract ChainlinkOracle_Fork_Test is BaseTest {
    BaseScriptMock internal baseScriptMock;

    /// @notice A modifier that runs the forked test for a given chain
    modifier initForkTest(string memory chainName) {
        // Fork chain on the latest block number.
        vm.createSelectFork({ urlOrAlias: chainName });

        baseScriptMock = new BaseScriptMock();

        // Get initial min fee USD and chainlink oracle address for `block.chainid`.
        uint256 initialMinFeeUSD = baseScriptMock.getInitialMinFeeUSD();
        address chainlinkOracle = baseScriptMock.getChainlinkOracle();

        // Deploy the Merkle Instant factory and create a new campaign.
        comptroller = new SablierComptroller({
            initialAdmin: admin,
            initialAirdropMinFeeUSD: initialMinFeeUSD,
            initialFlowMinFeeUSD: initialMinFeeUSD,
            initialLockupMinFeeUSD: initialMinFeeUSD,
            initialOracle: chainlinkOracle
        });

        // Assert that the Chainlink returns a non-zero price by checking the value of min fee in wei.
        vm.assertLt(0, comptroller.calculateAirdropsMinFeeWei(), "min fee wei");
        vm.assertLt(0, comptroller.calculateFlowMinFeeWei(), "min fee wei");
        vm.assertLt(0, comptroller.calculateLockupMinFeeWei(), "min fee wei");

        _;
    }

    function testFork_ChainlinkOracle_Arbitrum() external initForkTest("arbitrum") { }

    function testFork_ChainlinkOracle_Avalanche() external initForkTest("avalanche") { }

    function testFork_ChainlinkOracle_Base() external initForkTest("base") { }

    function testFork_ChainlinkOracle_BSC() external initForkTest("bsc") { }

    function testFork_ChainlinkOracle_Ethereum() external initForkTest("ethereum") { }

    function testFork_ChainlinkOracle_Gnosis() external initForkTest("gnosis") { }

    function testFork_ChainlinkOracle_Linea() external initForkTest("linea") { }

    function testFork_ChainlinkOracle_Optimism() external initForkTest("optimism") { }

    function testFork_ChainlinkOracle_Polygon() external initForkTest("polygon") { }

    function testFork_ChainlinkOracle_Scroll() external initForkTest("scroll") { }

    function testFork_ChainlinkOracle_Zksync() external initForkTest("zksync") { }
}
