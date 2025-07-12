// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Errors } from "src/libraries/Errors.sol";
import { IComptrollerable } from "src/interfaces/IComptrollerable.sol";
import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";
import { ComptrollerWithoutCoreInterfaceId } from "src/mocks/ComptrollerMock.sol";
import { SablierComptroller } from "src/SablierComptroller.sol";

import { Base_Test } from "../../../../Base.t.sol";

contract SetComptroller_Comptrollerable_Concrete_Test is Base_Test {
    ISablierComptroller internal newComptroller;

    function setUp() public override {
        super.setUp();

        // Deploy a new comptroller.
        newComptroller = new SablierComptroller(admin, 0, 0, 0, address(oracle));
    }

    function test_RevertWhen_CallerNotCurrentComptroller() external {
        setMsgSender(admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.Comptrollerable_CallerNotComptroller.selector, comptroller, admin)
        );
        comptrollerableMock.setComptroller(newComptroller);
    }

    function test_RevertWhen_NewComptrollerWithoutCoreInterfaceId() external whenCallerCurrentComptroller {
        address newComptrollerWithoutCoreInterfaceId = address(new ComptrollerWithoutCoreInterfaceId());

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SablierComptroller_UnsupportedInterfaceId.selector,
                comptroller,
                newComptrollerWithoutCoreInterfaceId,
                comptroller.CORE_INTERFACE_ID()
            )
        );
        comptrollerableMock.setComptroller(ISablierComptroller(newComptrollerWithoutCoreInterfaceId));
    }

    function test_WhenNewComptrollerWithCoreInterfaceId() external whenCallerCurrentComptroller {
        vm.expectEmit({ emitter: address(comptrollerableMock) });
        emit IComptrollerable.SetComptroller(comptroller, newComptroller);
        comptrollerableMock.setComptroller(newComptroller);
        assertEq(address(comptrollerableMock.comptroller()), address(newComptroller), "Comptroller not set correctly");
    }
}
