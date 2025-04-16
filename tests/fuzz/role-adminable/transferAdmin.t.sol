// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IRoleAdminable } from "src/interfaces/IRoleAdminable.sol";
import { Errors } from "src/libraries/Errors.sol";

import { RoleAdminableMock } from "src/mocks/RoleAdminableMock.sol";
import { Unit_Test } from "../../Unit.t.sol";

contract TransferAdmin_RoleAdminable_Unit_Fuzz_Test is Unit_Test {
    RoleAdminableMock internal roleAdminableMock;

    function setUp() public override {
        Unit_Test.setUp();

        roleAdminableMock = new RoleAdminableMock(admin);
        setMsgSender(admin);
    }

    function testFuzz_RevertWhen_CallerNotAdmin(address eve) external {
        vm.assume(eve != address(0) && eve != admin);
        assumeNotPrecompile(eve);

        // Make Eve the caller in this test.
        setMsgSender(eve);

        // Run the test.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, eve));
        roleAdminableMock.transferAdmin(eve);
    }

    function testFuzz_TransferAdmin(address newAdmin) external whenCallerAdmin {
        vm.assume(newAdmin != address(0));

        // It should emit {TransferAdmin} event.
        vm.expectEmit({ emitter: address(roleAdminableMock) });
        emit IRoleAdminable.TransferAdmin(admin, newAdmin);

        // Transfer the admin.
        roleAdminableMock.transferAdmin(newAdmin);

        // Assert that the admin has been transferred.
        address actualAdmin = roleAdminableMock.admin();
        assertEq(actualAdmin, newAdmin, "admin");
    }
}
