// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import {
    ChainlinkOracleOutdated,
    ChainlinkOracleFuture,
    ChainlinkOracleWith18Decimals,
    ChainlinkOracleWith6Decimals,
    ChainlinkOracleZeroPrice
} from "src/mocks/ChainlinkMocks.sol";

import { SablierComptroller_Unit_Concrete_Test } from "../SablierComptroller.t.sol";

contract Calculations_Unit_Concrete_Test is SablierComptroller_Unit_Concrete_Test {
    function test_CalculateMinFeeWeiGivenOracleZero() external {
        comptroller.setOracle(address(0));

        // It should return zero.
        assertEq(comptrollerZero.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier givenOracleNotZero() {
        _;
    }

    function test_CalculateMinFeeWei_WhenMinFeeUSDZero() external view givenOracleNotZero {
        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(0), 0, "min fee wei");
    }

    modifier whenMinFeeUSDNotZero() {
        _;
    }

    function test_CalculateMinFeeWei_WhenOracleUpdatedTimeInFuture() external givenOracleNotZero whenMinFeeUSDNotZero {
        comptroller.setOracle(address(new ChainlinkOracleFuture()));

        // It should return zero.
        assertEq(comptroller.calculateMinFeeWei(AIRDROP_MIN_FEE_USD), 0, "min fee wei");
    }

    modifier whenOracleUpdatedTimeNotInFuture() {
        _;
    }

    function test_CalculateMinFeeWei_WhenOraclePriceOutdated()
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

    function test_CalculateMinFeeWei_WhenOraclePriceZero()
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

    function test_CalculateMinFeeWei_WhenOraclePriceHasEightDecimals()
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

    function test_CalculateMinFeeWei_WhenOraclePriceHasMoreThanEightDecimals()
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

    function test_CalculateMinFeeWei_WhenOraclePriceHasLessThanEightDecimals()
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
                                      AIRDROPS
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiAirdropsGivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiAirdrops(), 0, "min fee wei airdrops not set");
    }

    function test_CalculateMinFeeWeiAirdropsGivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiAirdrops(), AIRDROP_MIN_FEE_WEI, "min fee wei airdrops set");
    }

    function test_CalculateMinFeeWeiAirdropsFor_GivenCustomFeeNotSet() external view {
        assertEq(
            comptrollerZero.calculateMinFeeWeiAirdropsFor(campaignCreator), 0, "min fee wei airdrops custom not set"
        );
    }

    function test_CalculateMinFeeWeiAirdropsFor_GivenCustomFeeSet() external view {
        assertEq(
            comptroller.calculateMinFeeWeiAirdropsFor(campaignCreator),
            AIRDROPS_CUSTOM_FEE_WEI,
            "min fee wei airdrops custom set"
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        FLOW
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiFlow_GivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiFlow(), 0, "min fee wei flow not set");
    }

    function test_CalculateMinFeeWeiFlow_GivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiFlow(), FLOW_MIN_FEE_WEI, "min fee wei flow set");
    }

    function test_CalculateMinFeeWeiFlowFor_GivenCustomFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiFlowFor(sender), 0, "min fee wei flow custom not set");
    }

    function test_CalculateMinFeeWeiFlowFor_GivenCustomFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiFlowFor(sender), FLOW_CUSTOM_FEE_WEI, "min fee wei flow custom set");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function test_CalculateMinFeeWeiLockup_GivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiLockup(), 0, "min fee wei lockup not set");
    }

    function test_CalculateMinFeeWeiLockup_GivenMinFeeSet() external view {
        assertEq(comptroller.calculateMinFeeWeiLockup(), LOCKUP_MIN_FEE_WEI, "min fee wei lockup set");
    }

    function test_CalculateMinFeeWeiLockupFor_GivenCustomFeeNotSet() external view {
        assertEq(comptrollerZero.calculateMinFeeWeiLockupFor(sender), 0, "min fee wei lockup custom not set");
    }

    function test_CalculateMinFeeWeiLockupFor_GivenCustomFeeSet() external view {
        assertEq(
            comptroller.calculateMinFeeWeiLockupFor(sender), LOCKUP_CUSTOM_FEE_WEI, "min fee wei lockup custom set"
        );
    }
}
