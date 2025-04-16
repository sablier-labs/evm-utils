// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IRoleAdminable } from "src/interfaces/IRoleAdminable.sol";
import { Errors } from "src/libraries/Errors.sol";

import { RoleAdminable_Unit_Concrete_Test } from "../RoleAdminable.t.sol";

contract TransferAdmin_RoleAdminable_Unit_Concrete_Test is RoleAdminable_Unit_Concrete_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        // Make Accountant the caller in this test.
        setMsgSender(accountant);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, accountant));
        roleAdminableMock.transferAdmin(accountant);
    }

    function test_WhenNewAdminSameAsCurrentAdmin() external whenCallerAdmin {
        // Transfer the admin to the same admin.
        _testTransferAdmin(admin, admin);
    }

    function test_WhenNewAdminZeroAddress() external whenCallerAdmin whenNewAdminNotSameAsCurrentAdmin {
        // Transfer the admin to the zero address.
        _testTransferAdmin(admin, address(0));
    }

    function test_WhenNewAdminNotZeroAddress() external whenCallerAdmin whenNewAdminNotSameAsCurrentAdmin {
        // Transfer the admin to Alice.
        _testTransferAdmin(admin, alice);
    }

    /// @dev Private function to test transfer admin.
    function _testTransferAdmin(address oldAdmin, address newAdmin) private {
        // It should emit {TransferAdmin} event.
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IRoleAdminable.TransferAdmin(oldAdmin, newAdmin);

        // Transfer the admin.
        roleAdminableMock.transferAdmin(newAdmin);

        // It should set the new admin.
        address actualAdmin = roleAdminableMock.admin();
        assertEq(actualAdmin, newAdmin, "admin");
    }
}
