// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import {
    ChainlinkOracleOutdated,
    ChainlinkOracleFuture,
    ChainlinkOracleWith18Decimals,
    ChainlinkOracleWith6Decimals,
    ChainlinkOracleZeroPrice
} from "src/mocks/ChainlinkMocks.sol";

import { SablierComptroller_Concrete_Test } from "../SablierComptroller.t.sol";

contract Calculations_Concrete_Test is SablierComptroller_Concrete_Test {
    /*//////////////////////////////////////////////////////////////////////////
                               CALCULATE-MIN-FEE-WEI
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiGivenOracleZero() external {
        comptroller.setOracle(address(0));

        // It should return zero.
        assertEq(comptrollerZero.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier givenOracleNotZero() {
        _;
    }

    function test_CalculateMinFeeWeiWhenMinFeeUSDZero() external view givenOracleNotZero {
        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(0), 0, "min fee wei");
    }

    modifier whenMinFeeUSDNotZero() {
        _;
    }

    function test_CalculateMinFeeWeiWhenOracleUpdatedTimeInFuture() external givenOracleNotZero whenMinFeeUSDNotZero {
        comptroller.setOracle(address(new ChainlinkOracleFuture()));

        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier whenOracleUpdatedTimeNotInFuture() {
        _;
    }

    function test_CalculateMinFeeWeiWhenOraclePriceOutdated()
        external
        givenOracleNotZero
        whenMinFeeUSDNotZero
        whenOracleUpdatedTimeNotInFuture
    {
        comptroller.setOracle(address(new ChainlinkOracleOutdated()));

        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier whenOraclePriceNotOutdated() {
        _;
    }

    function test_CalculateMinFeeWeiWhenOraclePriceZero()
        external
        givenOracleNotZero
        whenMinFeeUSDNotZero
        whenOracleUpdatedTimeNotInFuture
        whenOraclePriceNotOutdated
    {
        comptroller.setOracle(address(new ChainlinkOracleZeroPrice()));

        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier whenOraclePriceNotZero() {
        _;
    }

    function test_CalculateMinFeeWeiWhenOraclePriceHasEightDecimals()
        external
        view
        givenOracleNotZero
        whenMinFeeUSDNotZero
        whenOracleUpdatedTimeNotInFuture
        whenOraclePriceNotOutdated
        whenOraclePriceNotZero
    {
        // It should calculate the min fee in wei.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), AIRDROP_MIN_FEE_WEI, "min fee wei");
    }

    function test_CalculateMinFeeWeiWhenOraclePriceHasMoreThanEightDecimals()
        external
        givenOracleNotZero
        whenMinFeeUSDNotZero
        whenOracleUpdatedTimeNotInFuture
        whenOraclePriceNotOutdated
        whenOraclePriceNotZero
    {
        comptroller.setOracle(address(new ChainlinkOracleWith18Decimals()));

        // It should calculate the min fee in wei.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), AIRDROP_MIN_FEE_WEI, "min fee wei");
    }

    function test_CalculateMinFeeWeiWhenOraclePriceHasLessThanEightDecimals()
        external
        givenOracleNotZero
        whenMinFeeUSDNotZero
        whenOracleUpdatedTimeNotInFuture
        whenOraclePriceNotOutdated
        whenOraclePriceNotZero
    {
        comptroller.setOracle(address(new ChainlinkOracleWith6Decimals()));

        // It should calculate the min fee in wei.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), AIRDROP_MIN_FEE_WEI, "min fee wei");
    }

    /*//////////////////////////////////////////////////////////////////////////
                           CALCULATE-MIN-FEE-WEI-AIRDROPS
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiAirdropsGivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiAirdrops(), 0, "min fee wei airdrops not set");
    }

    function test_CalculateMinFeeWeiAirdropsGivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiAirdrops(), AIRDROP_MIN_FEE_WEI, "min fee wei airdrops set");
    }

    /*//////////////////////////////////////////////////////////////////////////
                         CALCULATE-MIN-FEE-WEI-AIRDROPS-FOR
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiAirdropsForGivenCustomFeeNotSet() external view {
        assertEq(
            comptrollerZero.calculateMinFeeWeiAirdropsFor(campaignCreator), 0, "min fee wei airdrops custom not set"
        );
    }

    function test_CalculateMinFeeWeiAirdropsForGivenCustomFeeSet() external view {
        assertEq(
            comptroller.calculateMinFeeWeiAirdropsFor(campaignCreator),
            AIRDROPS_CUSTOM_FEE_WEI,
            "min fee wei airdrops custom set"
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                             CALCULATE-MIN-FEE-WEI-FLOW
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiFlowGivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiFlow(), 0, "min fee wei flow not set");
    }

    function test_CalculateMinFeeWeiFlowGivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiFlow(), FLOW_MIN_FEE_WEI, "min fee wei flow set");
    }

    /*//////////////////////////////////////////////////////////////////////////
                           CALCULATE-MIN-FEE-WEI-FLOW-FOR
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiFlowForGivenCustomFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiFlowFor(sender), 0, "min fee wei flow custom not set");
    }

    function test_CalculateMinFeeWeiFlowForGivenCustomFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiFlowFor(sender), FLOW_CUSTOM_FEE_WEI, "min fee wei flow custom set");
    }

    /*//////////////////////////////////////////////////////////////////////////
                            CALCULATE-MIN-FEE-WEI-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiLockupGivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiLockup(), 0, "min fee wei lockup not set");
    }

    function test_CalculateMinFeeWeiLockupGivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiLockup(), LOCKUP_MIN_FEE_WEI, "min fee wei lockup set");
    }

    /*//////////////////////////////////////////////////////////////////////////
                          CALCULATE-MIN-FEE-WEI-LOCKUP-FOR
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiLockupForGivenCustomFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiLockupFor(sender), 0, "min fee wei lockup custom not set");
    }

    function test_CalculateMinFeeWeiLockupForGivenCustomFeeSet() external view {
        assertEq(
            comptroller.calculateMinFeeWeiLockupFor(sender), LOCKUP_CUSTOM_FEE_WEI, "min fee wei lockup custom set"
        );
    }
}
