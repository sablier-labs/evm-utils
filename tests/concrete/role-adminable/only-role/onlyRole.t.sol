// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { RoleAdminable_Unit_Concrete_Test } from "../RoleAdminable.t.sol";

contract OnlyRole_RoleAdminable_Unit_Concrete_Test is RoleAdminable_Unit_Concrete_Test {
    function test_WhenCallerAdmin() external {
        // It should execute the function.
        roleAdminableMock.restrictedToRole();
    }

    modifier whenCallerNotAdmin() {
        _;
    }

    function test_RevertWhen_CallerDoesNotHaveRole() external whenCallerNotAdmin {
        setMsgSender(eve);

        vm.expectRevert(abi.encodeWithSelector(Errors.CallerWithoutRoleOrNotAdmin.selector, eve, FEE_COLLECTOR_ROLE));
        roleAdminableMock.restrictedToRole();
    }

    function test_WhenCallerHasRole() external whenCallerNotAdmin {
        // Grant role to Eve.
        roleAdminableMock.grantRole(FEE_COLLECTOR_ROLE, eve);

        setMsgSender(eve);

        // It should execute the function.
        roleAdminableMock.restrictedToRole();
    }
}
