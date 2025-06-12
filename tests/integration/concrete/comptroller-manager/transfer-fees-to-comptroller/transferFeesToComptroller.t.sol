// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";

import { Base_Test } from "../../../../Base.t.sol";

contract TransferFeesToComptroller_Lockup_Integration_Concrete_Test is Base_Test {
    function setUp() public virtual override {
        Base_Test.setUp();
    }

    function test_GivenFeeZero() external {
        vm.expectEmit({ emitter: address(comptrollerManager) });
        emit IComptrollerManager.TransferFeesToComptroller(comptroller, 0);
        comptrollerManager.transferFeesToComptroller();
    }

    function test_GivenFeeNotZero() external {
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
