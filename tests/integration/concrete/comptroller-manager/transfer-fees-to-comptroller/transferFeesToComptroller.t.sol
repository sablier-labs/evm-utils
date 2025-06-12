// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";

import { Base_Test } from "../../../../Base.t.sol";

contract TransferFeesToComptroller_Lockup_Integration_Concrete_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function test_RevertGiven_ComptrollerNotImplementReceive() external {
        setMsgSender(address(comptroller));
        comptrollerManager.setComptroller(ISablierComptroller(address(contractWithoutReceive)));

        // Fund the lockup with fees to transfer.
        vm.deal(address(comptrollerManager), 1 ether);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ComptrollerManager_FeeTransferFailed.selector,
                address(contractWithoutReceive),
                address(comptrollerManager).balance
            )
        );
        comptrollerManager.transferFeesToComptroller();
    }

    modifier givenComptrollerImplementsReceive() {
        _;
    }

    function test_GivenFeeZero() external givenComptrollerImplementsReceive {
        vm.expectEmit({ emitter: address(comptrollerManager) });
        emit IComptrollerManager.TransferFeesToComptroller(comptroller, 0);
        comptrollerManager.transferFeesToComptroller();
    }

    function test_GivenFeeNotZero() external givenComptrollerImplementsReceive {
        vm.deal(address(comptrollerManager), LOCKUP_MIN_FEE_WEI);

        uint256 balanceBefore = address(comptroller).balance;

        vm.expectEmit({ emitter: address(comptrollerManager) });
        emit IComptrollerManager.TransferFeesToComptroller(comptroller, LOCKUP_MIN_FEE_WEI);
        comptrollerManager.transferFeesToComptroller();

        assertEq(
            address(comptroller).balance, balanceBefore + LOCKUP_MIN_FEE_WEI, "Fees not transferred to comptroller"
        );
    }
}
