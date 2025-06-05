// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { SablierComptroller } from "src/SablierComptroller.sol";
import { ChainlinkOracleMock } from "src/mocks/ChainlinkMocks.sol";

import { Unit_Test } from "../../Unit.t.sol";

abstract contract SablierComptroller_Unit_Concrete_Test is Unit_Test {
    ChainlinkOracleMock internal oracle;
    SablierComptroller internal comptroller;

    address internal campaignCreator;
    address internal sender;

    uint256 internal constant AIRDROP_MIN_FEE_USD = 3e8; // equivalent to $3
    uint256 internal constant AIRDROPS_CUSTOM_FEE_USD = 0.5e8; // equivalent to $0.5
    uint256 internal constant FLOW_MIN_FEE_USD = 1e8; // equivalent to $1
    uint256 internal constant FLOW_CUSTOM_FEE_USD = 0.1e8; // equivalent to $0.1
    uint256 internal constant LOCKUP_MIN_FEE_USD = 1e8; // equivalent to $1
    uint256 internal constant LOCKUP_CUSTOM_FEE_USD = 0.1e8; // equivalent to $0.1
    uint256 internal constant MAX_FEE_USD = 100e8; // equivalent to $100

    function setUp() public virtual override {
        Unit_Test.setUp();

        campaignCreator = createUser("campaignCreator", noSpenders);
        sender = createUser("sender", noSpenders);

        // Deploy the mock Chainlink Oracle.
        oracle = new ChainlinkOracleMock();

        // Deploy the Sablier Comptroller with minimum fees and the mock oracle.
        comptroller =
            new SablierComptroller(admin, AIRDROP_MIN_FEE_USD, FLOW_MIN_FEE_USD, LOCKUP_MIN_FEE_USD, address(oracle));

        // Set the accountant role.
        setMsgSender(admin);

        // Grant role to the accountant.
        grantAllRoles({ account: accountant, target: address(comptroller) });

        // Set the custom fees.
        comptroller.setAirdropsCustomFeeUSD(campaignCreator, AIRDROPS_CUSTOM_FEE_USD);
        comptroller.setFlowCustomFeeUSD(sender, FLOW_CUSTOM_FEE_USD);
        comptroller.setLockupCustomFeeUSD(sender, LOCKUP_CUSTOM_FEE_USD);

        // Assert the state variables.
        assertEq(comptroller.admin(), admin, "admin");
        assertEq(comptroller.getAirdropsMinFeeUSD(), AIRDROP_MIN_FEE_USD, "airdrop min fee");
        assertEq(comptroller.getFlowMinFeeUSD(), FLOW_MIN_FEE_USD, "flow min fee");
        assertEq(comptroller.getLockupMinFeeUSD(), LOCKUP_MIN_FEE_USD, "lockup min fee");
        assertEq(comptroller.MAX_FEE_USD(), 100e8, "max fee USD");
    }
}
