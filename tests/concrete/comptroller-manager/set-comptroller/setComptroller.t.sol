// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Errors } from "src/libraries/Errors.sol";
import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ComptrollerManager_Unit_Concrete_Test } from "../ComptrollerManager.t.sol";

contract SetComptroller_ComptrollerManager_Unit_Concrete_Test is ComptrollerManager_Unit_Concrete_Test {
    bytes internal data;

    function setUp() public override {
        ComptrollerManager_Unit_Concrete_Test.setUp();
        data = abi.encodeCall(IComptrollerManager.setComptroller, (admin));
    }

    function test_RevertWhen_CallerNotCurrentComptroller() external {
        setMsgSender(admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.ComptrollerManager_CallerNotComptroller.selector, address(comptroller), admin)
        );
        comptrollerManager.setComptroller(admin);
    }

    modifier whenCallerCurrentComptroller() {
        _;
    }

    function test_RevertWhen_NewComptrollerZeroAddress() external whenCallerCurrentComptroller {
        setMsgSender(address(comptroller));
        vm.expectRevert(abi.encodeWithSelector(Errors.ComptrollerManager_InvalidComptrollerAddress.selector));
        comptrollerManager.setComptroller(address(0));
    }

    function test_WhenNewComptrollerNotZeroAddress() external whenCallerCurrentComptroller {
        vm.expectEmit({ emitter: address(comptrollerManager) });
        emit IComptrollerManager.SetComptroller(admin, address(comptroller));
        comptroller.execute({ target: address(comptrollerManager), data: data });
        assertEq(address(comptrollerManager.comptroller()), admin, "Comptroller not set correctly");
    }
}
