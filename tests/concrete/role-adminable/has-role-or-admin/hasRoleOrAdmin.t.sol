// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { RoleAdminable_Unit_Concrete_Test } from "../RoleAdminable.t.sol";

contract HasRoleOrAdmin_RoleAdminable_Unit_Concrete_Test is RoleAdminable_Unit_Concrete_Test {
    function test_WhenCallerAdmin() external view {
        // It should return true.
        bool actualHasRole = roleAdminableMock.hasRoleOrAdmin(FEE_COLLECTOR_ROLE);
        assertTrue(actualHasRole, "hasRoleOrAdmin");
    }

    modifier whenCallerNotAdmin() {
        _;
    }

    function test_WhenCallerHasRole() external whenCallerNotAdmin {
        // Grant role to eve.
        roleAdminableMock.grantRole(FEE_COLLECTOR_ROLE, eve);

        // Change `msg.sender` to eve.
        setMsgSender(eve);

        // It should return true.
        bool actualHasRole = roleAdminableMock.hasRoleOrAdmin(FEE_COLLECTOR_ROLE);
        assertTrue(actualHasRole, "hasRoleOrAdmin");
    }

    function test_WhenCallerDoesNotHaveRole() external whenCallerNotAdmin {
        // Change `msg.sender` to eve.
        setMsgSender(eve);

        // It should return false.
        bool actualHasRole = roleAdminableMock.hasRoleOrAdmin(FEE_COLLECTOR_ROLE);
        assertFalse(actualHasRole, "hasRoleOrAdmin");
    }
}
