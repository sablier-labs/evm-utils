// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { SablierComptroller_Unit_Concrete_Test } from "../SablierComptroller.t.sol";

import { SablierComptroller } from "src/SablierComptroller.sol";

contract Getters_Unit_Concrete_Test is SablierComptroller_Unit_Concrete_Test {
    function test_GetAirdropsMinFeeUSD_GivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.getAirdropsMinFeeUSD(), 0, "airdrop min fee USD not set");
    }

    function test_GetAirdropsMinFeeUSD_GivenMinFeeSet() external view {
        assertEq(comptroller.getAirdropsMinFeeUSD(), AIRDROP_MIN_FEE_USD, "airdrop min fee USD set");
    }

    function test_GetAirdropsCustomFeeUSD_GivenCustomFeeUSDNotSet() external view {
        assertEq(comptrollerZero.getAirdropsMinFeeUSDFor(campaignCreator), 0, "airdrop custom fee USD not set");
    }

    function test_GetAirdropsCustomFeeUSD_GivenCustomFeeUSDSet() external view {
        assertEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator), AIRDROPS_CUSTOM_FEE_USD, "airdrop custom fee USD set"
        );
    }

    function test_GetFlowMinFeeUSD_GivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.getFlowMinFeeUSD(), 0, "flow min fee USD not set");
    }

    function test_GetFlowMinFeeUSD_GivenMinFeeSet() external view {
        assertEq(comptroller.getFlowMinFeeUSD(), FLOW_MIN_FEE_USD, "flow min fee USD set");
    }

    function test_GetFlowCustomFeeUSD_GivenCustomFeeUSDNotSet() external view {
        assertEq(comptrollerZero.getFlowMinFeeUSDFor(sender), 0, "flow custom fee USD not set");
    }

    function test_GetFlowCustomFeeUSD_GivenCustomFeeUSDSet() external view {
        assertEq(comptroller.getFlowMinFeeUSDFor(sender), FLOW_CUSTOM_FEE_USD, "flow custom fee USD set");
    }

    function test_GetLockupMinFeeUSD_GivenMinFeeNotSet() external view {
        assertEq(comptrollerZero.getLockupMinFeeUSD(), 0, "lockup min fee USD not set");
    }

    function test_GetLockupMinFeeUSD_GivenMinFeeSet() external view {
        assertEq(comptroller.getLockupMinFeeUSD(), LOCKUP_MIN_FEE_USD, "lockup min fee USD set");
    }

    function test_GetLockupCustomFeeUSD_GivenCustomFeeUSDNotSet() external view {
        assertEq(comptrollerZero.getLockupMinFeeUSDFor(sender), 0, "lockup custom fee USD not set");
    }

    function test_GetLockupCustomFeeUSD_GivenCustomFeeUSDSet() external view {
        assertEq(comptroller.getLockupMinFeeUSDFor(sender), LOCKUP_CUSTOM_FEE_USD, "lockup custom fee USD set");
    }

    function test_Oracle_GivenOracleNotSet() external view {
        assertEq(comptrollerZero.oracle(), address(0), "oracle not set");
    }

    function test_Oracle_GivenOracleSet() external view {
        assertEq(comptroller.oracle(), address(oracle), "oracle set");
    }
}
