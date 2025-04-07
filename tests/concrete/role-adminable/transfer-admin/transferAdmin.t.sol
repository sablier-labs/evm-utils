// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { IRoleAdminable } from "src/interfaces/IRoleAdminable.sol";
import { Errors } from "src/libraries/Errors.sol";

import { RoleAdminable_Unit_Concrete_Test } from "../RoleAdminable.t.sol";

contract TransferAdmin_RoleAdminable_Unit_Concrete_Test is RoleAdminable_Unit_Concrete_Test {
    function test_RevertWhen_CallerNotAdmin() external {
        // Make Eve the caller in this test.
        setMsgSender(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, eve));
        roleAdminableMock.transferAdmin(eve);
    }

    modifier whenCallerAdmin() {
        _;
    }

    function test_WhenNewAdminSameAsCurrentAdmin() external whenCallerAdmin {
        // It should emit {RoleRevoked}, {RoleGranted} and {TransferAdmin} events.
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleRevoked({ role: DEFAULT_ADMIN_ROLE, account: admin, sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleGranted({ role: DEFAULT_ADMIN_ROLE, account: admin, sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IRoleAdminable.TransferAdmin({ oldAdmin: admin, newAdmin: admin });

        // Transfer the admin.
        roleAdminableMock.transferAdmin(admin);

        // It should keep the same admin.
        address actualAdmin = roleAdminableMock.admin();
        address expectedAdmin = admin;
        assertEq(actualAdmin, expectedAdmin, "admin");

        // It should keep the admin role.
        bool actualHasRole = roleAdminableMock.hasRole(DEFAULT_ADMIN_ROLE, admin);
        assertTrue(actualHasRole, "hasRole");
    }

    modifier whenNewAdminNotSameAsCurrentAdmin() {
        _;
    }

    function test_WhenNewAdminZeroAddress() external whenCallerAdmin whenNewAdminNotSameAsCurrentAdmin {
        // It should emit {RoleRevoked}, {RoleGranted} and {TransferAdmin} events.
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleRevoked({ role: DEFAULT_ADMIN_ROLE, account: admin, sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleGranted({ role: DEFAULT_ADMIN_ROLE, account: address(0), sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IRoleAdminable.TransferAdmin({ oldAdmin: admin, newAdmin: address(0) });

        // Transfer the admin.
        roleAdminableMock.transferAdmin(address(0));

        // It should set the admin to the zero address.
        address actualAdmin = roleAdminableMock.admin();
        address expectedAdmin = address(0);
        assertEq(actualAdmin, expectedAdmin, "admin");

        // It should revoke the admin role.
        bool actualHasRole = roleAdminableMock.hasRole(DEFAULT_ADMIN_ROLE, admin);
        assertFalse(actualHasRole, "hasRole");
    }

    function test_WhenNewAdminNotZeroAddress() external whenCallerAdmin whenNewAdminNotSameAsCurrentAdmin {
        // It should emit {RoleRevoked}, {RoleGranted} and {TransferAdmin} events.
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleRevoked({ role: DEFAULT_ADMIN_ROLE, account: admin, sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IAccessControl.RoleGranted({ role: DEFAULT_ADMIN_ROLE, account: alice, sender: admin });
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IRoleAdminable.TransferAdmin({ oldAdmin: admin, newAdmin: alice });

        // Transfer the admin.
        roleAdminableMock.transferAdmin(alice);

        // It should set the new admin.
        address actualAdmin = roleAdminableMock.admin();
        address expectedAdmin = alice;
        assertEq(actualAdmin, expectedAdmin, "admin");

        // It should revoke the admin role from the old admin.
        bool actualHasRole = roleAdminableMock.hasRole(DEFAULT_ADMIN_ROLE, admin);
        assertFalse(actualHasRole, "hasRole");

        // It should grant the admin role to alice.
        actualHasRole = roleAdminableMock.hasRole(DEFAULT_ADMIN_ROLE, alice);
        assertTrue(actualHasRole, "hasRole");
    }
}
