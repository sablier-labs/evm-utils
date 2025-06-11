// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Errors } from "src/libraries/Errors.sol";
import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";
import { ComptrollerManager_Unit_Concrete_Test } from "../ComptrollerManager.t.sol";

contract SetComptroller_ComptrollerManager_Unit_Concrete_Test is ComptrollerManager_Unit_Concrete_Test {
    ISablierComptroller internal newComptroller;

    function setUp() public override {
        ComptrollerManager_Unit_Concrete_Test.setUp();
        newComptroller = ISablierComptroller(admin);
    }

    function test_RevertWhen_CallerNotCurrentComptroller() external {
        setMsgSender(admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.ComptrollerManager_CallerNotComptroller.selector, comptroller, admin)
        );
        comptrollerManager.setComptroller(newComptroller);
    }

    modifier whenCallerCurrentComptroller() {
        setMsgSender(address(comptroller));
        _;
    }

    function test_RevertWhen_NewComptrollerZeroAddress() external whenCallerCurrentComptroller {
        vm.expectRevert(Errors.ComptrollerManager_ZeroAddress.selector);
        comptrollerManager.setComptroller(ISablierComptroller(address(0)));
    }

    function test_WhenNewComptrollerNotZeroAddress() external whenCallerCurrentComptroller {
        vm.expectEmit({ emitter: address(comptrollerManager) });
        emit IComptrollerManager.SetComptroller(newComptroller, comptroller);
        comptrollerManager.setComptroller(newComptroller);
        assertEq(address(comptrollerManager.comptroller()), address(newComptroller), "Comptroller not set correctly");
    }
}
