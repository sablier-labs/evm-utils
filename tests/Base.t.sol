// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StdAssertions } from "forge-std/src/StdAssertions.sol";
import { AdminableMock } from "src/mocks/AdminableMock.sol";
import { BatchMock } from "src/mocks/BatchMock.sol";
import { ComptrollerManagerMock } from "src/mocks/ComptrollerManagerMock.sol";
import { NoDelegateCallMock } from "src/mocks/NoDelegateCallMock.sol";
import { RoleAdminableMock } from "src/mocks/RoleAdminableMock.sol";
import { BaseTest } from "src/tests/BaseTest.sol";

import { Modifiers } from "./utils/Modifiers.sol";

/// @notice Base test contract with common logic needed by all tests.
abstract contract Base_Test is BaseTest, Modifiers, StdAssertions {
    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    uint40 public constant FEB_1_2025 = 1_738_368_000;

    /*//////////////////////////////////////////////////////////////////////////
                                     TEST-USERS
    //////////////////////////////////////////////////////////////////////////*/

    address internal accountant;
    address internal alice;
    address internal campaignCreator;
    address internal eve;
    address[] internal noSpenders;
    address internal sender;

    /*//////////////////////////////////////////////////////////////////////////
                                   MOCK-CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    AdminableMock internal adminableMock;
    BatchMock internal batchMock;
    ComptrollerManagerMock internal comptrollerManagerMock;
    NoDelegateCallMock internal noDelegateCallMock;
    RoleAdminableMock internal roleAdminableMock;

    /*//////////////////////////////////////////////////////////////////////////
                                       SET-UP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        BaseTest.setUp();

        // Create the test users.
        accountant = createUser("accountant", noSpenders);
        alice = createUser("alice", noSpenders);
        campaignCreator = createUser("campaignCreator", noSpenders);
        eve = createUser("eve", noSpenders);
        sender = createUser("sender", noSpenders);

        // Deploy mock contracts.
        adminableMock = new AdminableMock(admin);
        batchMock = new BatchMock();
        comptrollerManagerMock = new ComptrollerManagerMock(address(comptroller));
        noDelegateCallMock = new NoDelegateCallMock();
        roleAdminableMock = new RoleAdminableMock(admin);

        // Set the admin as the msg.sender.
        setMsgSender(admin);

        // Grant all the roles to the accountant.
        grantAllRoles({ account: accountant, target: address(comptroller) });
        grantAllRoles({ account: accountant, target: address(roleAdminableMock) });

        // Warp to Feb 1, 2025 at 00:00 UTC to provide a more realistic testing environment.
        vm.warp({ newTimestamp: FEB_1_2025 });
    }
}
