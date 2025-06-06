// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { stdError } from "forge-std/src/StdError.sol";

import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";
import { Errors } from "src/libraries/Errors.sol";
import { AdminableMock } from "src/mocks/AdminableMock.sol";

import { TargetPanic } from "./targets/TargetPanic.sol";
import { TargetReverter } from "./targets/TargetReverter.sol";
import { SablierComptroller_Unit_Concrete_Test } from "../SablierComptroller.t.sol";

contract Execute_Unit_Concrete_Test is SablierComptroller_Unit_Concrete_Test {
    address internal target;

    struct Targets {
        AdminableMock adminable;
        TargetPanic panic;
        TargetReverter reverter;
    }

    Targets internal targets;

    bytes internal data;

    function setUp() public override {
        SablierComptroller_Unit_Concrete_Test.setUp();

        // Create the targets.
        targets = Targets({
            adminable: new AdminableMock(address(comptroller)),
            panic: new TargetPanic(),
            reverter: new TargetReverter()
        });

        data = abi.encodeCall(targets.adminable.transferAdmin, (admin));
    }

    function test_RevertWhen_CallerNotAdmin() external {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, eve));
        comptroller.execute({ target: address(targets.adminable), data: data });
    }

    function test_RevertWhen_TargetNotContract() external whenCallerAdmin {
        comptroller.execute({ target: address(0), data: data });
    }

    modifier whenTargetContract() {
        _;
    }

    modifier whenTheCallCallReverts() {
        _;
    }

    function test_WhenTheExceptionIsAPanic() external whenCallerAdmin whenTargetContract whenTheCallCallReverts {
        // It should panic due to a failed assertion
        data = bytes.concat(targets.panic.failedAssertion.selector);
        vm.expectRevert(stdError.assertionError);
        comptroller.execute(address(targets.panic), data);

        // It should panic due to an arithmetic overflow
        data = bytes.concat(targets.panic.arithmeticOverflow.selector);
        vm.expectRevert(stdError.arithmeticError);
        comptroller.execute(address(targets.panic), data);

        // It should panic due to a division by zero
        data = bytes.concat(targets.panic.divisionByZero.selector);
        vm.expectRevert(stdError.divisionError);
        comptroller.execute(address(targets.panic), data);

        // It should panic due to an index out of bounds
        data = bytes.concat(targets.panic.indexOOB.selector);
        vm.expectRevert(stdError.indexOOBError);
        comptroller.execute(address(targets.panic), data);
    }

    function test_WhenTheExceptionIsAnError() external whenCallerAdmin whenTargetContract whenTheCallCallReverts {
        // It should revert with an empty revert statement
        data = bytes.concat(targets.reverter.withNothing.selector);
        vm.expectRevert(Errors.SablierComptroller_ExecutionFailed.selector);
        comptroller.execute(address(targets.reverter), data);

        // It should revert with a custom error
        data = bytes.concat(targets.reverter.withCustomError.selector);
        vm.expectRevert(TargetReverter.SomeError.selector);
        comptroller.execute(address(targets.reverter), data);

        // It should revert with a require
        data = bytes.concat(targets.reverter.withRequire.selector);
        vm.expectRevert("You shall not pass");
        comptroller.execute(address(targets.reverter), data);

        // It should revert with a reason string
        data = bytes.concat(targets.reverter.withReasonString.selector);
        vm.expectRevert("You shall not pass");
        comptroller.execute(address(targets.reverter), data);
    }

    function test_WhenTheCallDoesNotRevert() external whenCallerAdmin whenTargetContract {
        // it should emit an {Execute} event
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.Execute({ target: address(targets.adminable), data: data, response: "" });

        comptroller.execute({ target: address(targets.adminable), data: data });

        // It should execute the call
        assertEq(
            targets.adminable.admin(), admin, "The admin of the target should be set to the admin of the comptroller"
        );
    }
}
