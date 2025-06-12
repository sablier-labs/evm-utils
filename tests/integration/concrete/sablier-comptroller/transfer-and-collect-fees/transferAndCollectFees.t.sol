// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";
import { Errors } from "src/libraries/Errors.sol";

import { SablierComptroller_Concrete_Test } from "../SablierComptroller.t.sol";

contract TransferAndCollectFees_Concrete_Test is SablierComptroller_Concrete_Test {
    SablierComptrollerManagerMockRevert internal comptrollerManagerRevert;

    function setUp() public override {
        SablierComptroller_Concrete_Test.setUp();

        comptrollerManagerRevert = new SablierComptrollerManagerMockRevert();

        // Fund the comptroller with some ETH to collect fees.
        deal(address(comptroller), AIRDROP_MIN_FEE_WEI);

        // Fund the ComptrollerManager with some ETH to transfer fees.
        deal(address(comptrollerManager), LOCKUP_MIN_FEE_WEI + FLOW_MIN_FEE_WEI);
    }

    function test_WhenCallerWithFeeCollectorRole() external whenCallerNotAdmin {
        _test_TransferAndCollectFees(users.accountant);
    }

    function test_RevertWhen_CallerWithoutFeeCollectorRole() external whenCallerNotAdmin {
        setMsgSender(users.eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, users.eve, FEE_COLLECTOR_ROLE));
        comptroller.transferAndCollectFees(address(comptrollerManager), address(comptrollerManager), admin);
    }

    function test_RevertWhen_TheFlowCallReverts() external whenCallerAdmin {
        setMsgSender(admin);
        vm.expectRevert();
        comptroller.transferAndCollectFees(address(comptrollerManagerRevert), address(comptrollerManager), admin);
    }

    function test_RevertWhen_TheLockupCallReverts() external whenCallerAdmin whenTheFlowCallNotRevert {
        setMsgSender(admin);
        vm.expectRevert();
        comptroller.transferAndCollectFees(address(comptrollerManager), address(comptrollerManagerRevert), admin);
    }

    function test_WhenTheLockupCallNotRevert() external whenCallerAdmin whenTheFlowCallNotRevert {
        _test_TransferAndCollectFees(admin);
    }

    function _test_TransferAndCollectFees(address caller) private {
        setMsgSender(caller);

        uint256 previousAdminBalance = admin.balance;
        uint256 totalFeeAmount = AIRDROP_MIN_FEE_WEI + LOCKUP_MIN_FEE_WEI + FLOW_MIN_FEE_WEI;

        // It should emit a {CollectFees} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.CollectFees({ feeRecipient: admin, feeAmount: totalFeeAmount });

        comptroller.transferAndCollectFees(address(comptrollerManager), address(comptrollerManager), admin);

        assertEq(address(comptrollerManager).balance, 0, "ComptrollerManager contract balance should be zero");
        assertEq(address(comptroller).balance, 0, "Comptroller balance should be zero");
        assertEq(admin.balance, previousAdminBalance + totalFeeAmount, "Admin balance should be increased");
    }
}

contract SablierComptrollerManagerMockRevert {
    function transferFeesToComptroller() external pure {
        revert();
    }
}
