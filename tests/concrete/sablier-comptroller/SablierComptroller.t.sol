// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { SablierComptroller } from "src/SablierComptroller.sol";
import { ChainlinkOracleMock } from "src/mocks/ChainlinkMocks.sol";

import { Unit_Test } from "../../Unit.t.sol";

abstract contract SablierComptroller_Unit_Concrete_Test is Unit_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint256 internal constant AIRDROP_MIN_FEE_USD = 3e8; // equivalent to $3
    uint256 public constant AIRDROP_MIN_FEE_WEI = (1e18 * AIRDROP_MIN_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant AIRDROPS_CUSTOM_FEE_USD = 0.5e8; // equivalent to $0.5
    uint256 internal constant AIRDROPS_CUSTOM_FEE_WEI = (1e18 * AIRDROPS_CUSTOM_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant FLOW_MIN_FEE_USD = 1e8; // equivalent to $1
    uint256 internal constant FLOW_MIN_FEE_WEI = (1e18 * FLOW_MIN_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant FLOW_CUSTOM_FEE_USD = 0.1e8; // equivalent to $0.1
    uint256 internal constant FLOW_CUSTOM_FEE_WEI = (1e18 * FLOW_CUSTOM_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant LOCKUP_MIN_FEE_USD = 1e8; // equivalent to $1
    uint256 internal constant LOCKUP_MIN_FEE_WEI = (1e18 * LOCKUP_MIN_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant LOCKUP_CUSTOM_FEE_USD = 0.1e8; // equivalent to $0.1
    uint256 internal constant LOCKUP_CUSTOM_FEE_WEI = (1e18 * LOCKUP_CUSTOM_FEE_USD) / 3000e8; // at $3000 per ETH
    uint256 internal constant MAX_FEE_USD = 100e8; // equivalent to $100
    uint40 public constant FEB_1_2025 = 1_738_368_000;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE-VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address internal campaignCreator;
    SablierComptroller internal comptroller;
    SablierComptroller internal comptrollerZero;
    ChainlinkOracleMock internal oracle;
    address internal sender;

    /*//////////////////////////////////////////////////////////////////////////
                                       SET-UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        Unit_Test.setUp();

        // Warp to Feb 1, 2025 at 00:00 UTC to provide a more realistic testing environment.
        vm.warp({ newTimestamp: FEB_1_2025 });

        campaignCreator = createUser("campaignCreator", noSpenders);
        sender = createUser("sender", noSpenders);

        // Deploy the mock Chainlink Oracle.
        oracle = new ChainlinkOracleMock();

        // Deploy the Sablier Comptroller with minimum fees and the mock oracle.
        comptroller =
            new SablierComptroller(admin, AIRDROP_MIN_FEE_USD, FLOW_MIN_FEE_USD, LOCKUP_MIN_FEE_USD, address(oracle));
        comptrollerZero = new SablierComptroller(admin, 0, 0, 0, address(0));

        // Grant role to the accountant.
        setMsgSender(admin);
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
