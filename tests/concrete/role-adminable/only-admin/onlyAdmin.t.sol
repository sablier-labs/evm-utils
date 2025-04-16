// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Errors } from "src/libraries/Errors.sol";
import { RoleAdminable_Unit_Concrete_Test } from "../RoleAdminable.t.sol";

contract OnlyAdmin_RoleAdminable_Unit_Concrete_Test is RoleAdminable_Unit_Concrete_Test {
    function test_WhenCallerAdmin() external {
        // It should execute the function.
        roleAdminableMock.restrictedToAdmin();
    }

    function test_RevertWhen_CallerNotHaveRole() external whenCallerNotAdmin {
        setMsgSender(eve);

        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, eve));
        roleAdminableMock.restrictedToAdmin();
    }

    function test_RevertWhen_CallerHasRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, accountant));
        roleAdminableMock.restrictedToAdmin();
    }
}
