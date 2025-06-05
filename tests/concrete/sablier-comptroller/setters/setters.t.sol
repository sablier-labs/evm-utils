// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";
import { Errors } from "src/libraries/Errors.sol";
import { Noop } from "src/mocks/Noop.sol";
import { ChainlinkOracleMock } from "src/mocks/ChainlinkMocks.sol";

import { SablierComptroller_Unit_Concrete_Test } from "../SablierComptroller.t.sol";

contract Setters_Unit_Concrete_Test is SablierComptroller_Unit_Concrete_Test {
    /*//////////////////////////////////////////////////////////////////////////
                                      AIRDROPS
    //////////////////////////////////////////////////////////////////////////*/

    function test_DisableAirdropsCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Enable the custom fee.
        comptroller.setAirdropsCustomFeeUSD({ campaignCreator: campaignCreator, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator),
            comptroller.getAirdropsMinFeeUSD(),
            "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableAirdropsCustomFeeUSD();
    }

    function test_DisableAirdropsCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.disableAirdropsCustomFeeUSD({ campaignCreator: campaignCreator });
    }

    function test_DisableAirdropsCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin {
        // Disable the custom fee.
        comptroller.disableAirdropsCustomFeeUSD({ campaignCreator: campaignCreator });

        // Check that custom fee is not enabled.
        assertEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator),
            comptroller.getAirdropsMinFeeUSD(),
            "custom fee USD enabled"
        );

        // Disable the custom fee.
        _disableAirdropsCustomFeeUSD();
    }

    function test_DisableAirdropsCustomFeeUSD_WhenEnabled() external whenCallerAdmin {
        // Enable the custom fee.
        comptroller.setAirdropsCustomFeeUSD({ campaignCreator: campaignCreator, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator),
            comptroller.getAirdropsMinFeeUSD(),
            "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableAirdropsCustomFeeUSD();
    }

    function _disableAirdropsCustomFeeUSD() private {
        // It should emit a {DisableAirdropsCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.DisableAirdropsCustomFeeUSD({ campaignCreator: campaignCreator });

        // Disable the custom fee.
        comptroller.disableAirdropsCustomFeeUSD({ campaignCreator: campaignCreator });

        // It should return the min USD fee.
        assertEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator), comptroller.getAirdropsMinFeeUSD(), "custom fee USD"
        );
    }

    function test_SetAirdropsCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the custom fee.
        _setAirdropsCustomFeeUSD();
    }

    function test_SetAirdropsCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setAirdropsCustomFeeUSD({ campaignCreator: campaignCreator, customFeeUSD: 0 });
    }

    function test_SetAirdropsCustomFeeUSD_RevertWhen_NewFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 customFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, customFeeUSD, MAX_FEE_USD)
        );
        comptroller.setAirdropsCustomFeeUSD(campaignCreator, customFeeUSD);
    }

    modifier whenNewFeeNotExceedMaxFee() {
        _;
    }

    function test_SetAirdropsCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        comptroller.disableAirdropsCustomFeeUSD(campaignCreator);

        // Check that custom fee is not enabled for user.
        assertEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator),
            comptroller.getAirdropsMinFeeUSD(),
            "custom fee USD enabled"
        );

        // Set the custom fee.
        _setAirdropsCustomFeeUSD();
    }

    function test_SetAirdropsCustomFeeUSD_WhenEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        // Enable the custom fee.
        comptroller.setAirdropsCustomFeeUSD({ campaignCreator: campaignCreator, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getAirdropsMinFeeUSDFor(campaignCreator),
            comptroller.getAirdropsMinFeeUSD(),
            "custom fee USD not enabled"
        );

        // Set the custom fee.
        _setAirdropsCustomFeeUSD();
    }

    function _setAirdropsCustomFeeUSD() private {
        // Set the custom fee to a different value.
        uint256 customFeeUSD = 0;

        // It should emit a {SetAirdropsCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetAirdropsCustomFeeUSD(campaignCreator, customFeeUSD);

        // Set the custom fee.
        comptroller.setAirdropsCustomFeeUSD(campaignCreator, customFeeUSD);

        // It should set the custom fee.
        assertEq(comptroller.getAirdropsMinFeeUSDFor(campaignCreator), customFeeUSD, "custom fee USD");
    }

    function test_SetAirdropsMinFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the min fee USD.
        _setAirdropsMinFeeUSD();
    }

    function test_SetAirdropsMinFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setAirdropsMinFeeUSD(0.001e18);
    }

    function test_SetAirdropsMinFeeUSD_RevertWhen_NewMinFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 newMinFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, newMinFeeUSD, MAX_FEE_USD)
        );
        comptroller.setAirdropsMinFeeUSD(newMinFeeUSD);
    }

    function test_SetAirdropsMinFeeUSD_WhenNewMinFeeNotExceedMaxFee() external whenCallerAdmin {
        // Set the min fee USD.
        _setAirdropsMinFeeUSD();
    }

    function _setAirdropsMinFeeUSD() private {
        uint256 newMinFeeUSD = MAX_FEE_USD;

        // It should emit a {SetMinFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetAirdropsMinFeeUSD({
            newMinFeeUSD: newMinFeeUSD,
            previousMinFeeUSD: AIRDROP_MIN_FEE_USD
        });

        comptroller.setAirdropsMinFeeUSD(newMinFeeUSD);

        // It should set the min USD fee.
        assertEq(comptroller.getAirdropsMinFeeUSD(), newMinFeeUSD, "min fee USD");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        FLOW
    //////////////////////////////////////////////////////////////////////////*/

    function test_DisableFlowCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Enable the custom fee.
        comptroller.setFlowCustomFeeUSD({ sender: sender, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableFlowCustomFeeUSD();
    }

    function test_DisableFlowCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.disableFlowCustomFeeUSD({ sender: sender });
    }

    function test_DisableFlowCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin {
        // Disable the custom fee.
        comptroller.disableFlowCustomFeeUSD({ sender: sender });

        // Check that custom fee is not enabled.
        assertEq(comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD enabled");

        // Disable the custom fee.
        _disableFlowCustomFeeUSD();
    }

    function test_DisableFlowCustomFeeUSD_WhenEnabled() external whenCallerAdmin {
        // Enable the custom fee.
        comptroller.setFlowCustomFeeUSD({ sender: sender, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableFlowCustomFeeUSD();
    }

    function _disableFlowCustomFeeUSD() private {
        // It should emit a {DisableFlowCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.DisableFlowCustomFeeUSD({ sender: sender });

        // Disable the custom fee.
        comptroller.disableFlowCustomFeeUSD({ sender: sender });

        // It should return the min USD fee.
        assertEq(comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD");
    }

    function test_SetFlowCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the custom fee.
        _setFlowCustomFeeUSD();
    }

    function test_SetFlowCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setFlowCustomFeeUSD(sender, 0);
    }

    function test_SetFlowCustomFeeUSD_RevertWhen_NewFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 customFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, customFeeUSD, MAX_FEE_USD)
        );
        comptroller.setFlowCustomFeeUSD(sender, customFeeUSD);
    }

    function test_SetFlowCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        comptroller.disableFlowCustomFeeUSD(sender);

        // Check that custom fee is not enabled for user.
        assertEq(comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD enabled");

        // Set the custom fee.
        _setFlowCustomFeeUSD();
    }

    function test_SetFlowCustomFeeUSD_WhenEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        // Enable the custom fee.
        comptroller.setFlowCustomFeeUSD(sender, 0.5e8);

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getFlowMinFeeUSDFor(sender), comptroller.getFlowMinFeeUSD(), "custom fee USD not enabled"
        );

        // Set the custom fee.
        _setFlowCustomFeeUSD();
    }

    function _setFlowCustomFeeUSD() private {
        // Set the custom fee to a different value.
        uint256 customFeeUSD = 0;

        // It should emit a {SetFlowCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetFlowCustomFeeUSD(sender, customFeeUSD);

        // Set the custom fee.
        comptroller.setFlowCustomFeeUSD(sender, customFeeUSD);

        // It should set the custom fee.
        assertEq(comptroller.getFlowMinFeeUSDFor(sender), customFeeUSD, "custom fee USD");
    }

    function test_SetFlowMinFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the min fee USD.
        _setFlowMinFeeUSD();
    }

    function test_SetFlowMinFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setFlowMinFeeUSD(0.001e18);
    }

    function test_SetFlowMinFeeUSD_RevertWhen_NewMinFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 newMinFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, newMinFeeUSD, MAX_FEE_USD)
        );
        comptroller.setFlowMinFeeUSD(newMinFeeUSD);
    }

    function test_SetFlowMinFeeUSD_WhenNewMinFeeNotExceedMaxFee() external whenCallerAdmin {
        // Set the min fee USD.
        _setFlowMinFeeUSD();
    }

    function _setFlowMinFeeUSD() private {
        uint256 newMinFeeUSD = MAX_FEE_USD;

        // It should emit a {SetMinFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetFlowMinFeeUSD({ newMinFeeUSD: newMinFeeUSD, previousMinFeeUSD: FLOW_MIN_FEE_USD });

        comptroller.setFlowMinFeeUSD(newMinFeeUSD);

        // It should set the min USD fee.
        assertEq(comptroller.getFlowMinFeeUSD(), newMinFeeUSD, "min fee USD");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    function test_DisableLockupCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Enable the custom fee.
        comptroller.setLockupCustomFeeUSD({ sender: sender, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableLockupCustomFeeUSD();
    }

    function test_DisableLockupCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.disableLockupCustomFeeUSD({ sender: sender });
    }

    function test_DisableLockupCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin {
        // Disable the custom fee.
        comptroller.disableLockupCustomFeeUSD({ sender: sender });

        // Check that custom fee is not enabled.
        assertEq(comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD enabled");

        // Disable the custom fee.
        _disableLockupCustomFeeUSD();
    }

    function test_DisableLockupCustomFeeUSD_WhenEnabled() external whenCallerAdmin {
        // Enable the custom fee.
        comptroller.setLockupCustomFeeUSD({ sender: sender, customFeeUSD: 0.5e8 });

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD not enabled"
        );

        // Disable the custom fee.
        _disableLockupCustomFeeUSD();
    }

    function _disableLockupCustomFeeUSD() private {
        // It should emit a {DisableLockupCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.DisableLockupCustomFeeUSD({ sender: sender });

        // Disable the custom fee.
        comptroller.disableLockupCustomFeeUSD({ sender: sender });

        // It should return the min USD fee.
        assertEq(comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD");
    }

    function test_SetLockupCustomFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the custom fee.
        _setLockupCustomFeeUSD();
    }

    function test_SetLockupCustomFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setLockupCustomFeeUSD(sender, 0);
    }

    function test_SetLockupCustomFeeUSD_RevertWhen_NewFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 customFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, customFeeUSD, MAX_FEE_USD)
        );
        comptroller.setLockupCustomFeeUSD(sender, customFeeUSD);
    }

    function test_SetLockupCustomFeeUSD_WhenNotEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        comptroller.disableLockupCustomFeeUSD(sender);

        // Check that custom fee is not enabled for user.
        assertEq(comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD enabled");

        // Set the custom fee.
        _setLockupCustomFeeUSD();
    }

    function test_SetLockupCustomFeeUSD_WhenEnabled() external whenCallerAdmin whenNewFeeNotExceedMaxFee {
        // Enable the custom fee.
        comptroller.setLockupCustomFeeUSD(sender, 0.5e8);

        // Check that custom fee is enabled.
        assertNotEq(
            comptroller.getLockupMinFeeUSDFor(sender), comptroller.getLockupMinFeeUSD(), "custom fee USD not enabled"
        );

        // Set the custom fee.
        _setLockupCustomFeeUSD();
    }

    function _setLockupCustomFeeUSD() private {
        // Set the custom fee to a different value.
        uint256 customFeeUSD = 0;

        // It should emit a {SetLockupCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetLockupCustomFeeUSD(sender, customFeeUSD);

        // Set the custom fee.
        comptroller.setLockupCustomFeeUSD(sender, customFeeUSD);

        // It should set the custom fee.
        assertEq(comptroller.getLockupMinFeeUSDFor(sender), customFeeUSD, "custom fee USD");
    }

    function test_SetLockupMinFeeUSD_WhenCallerWithFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(accountant);

        // Set the min fee USD.
        _setLockupMinFeeUSD();
    }

    function test_SetLockupMinFeeUSD_RevertWhen_CallerWithoutFeeManagementRole() external whenCallerNotAdmin {
        setMsgSender(eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, eve, FEE_MANAGEMENT_ROLE));
        comptroller.setLockupMinFeeUSD(0.001e18);
    }

    function test_SetLockupMinFeeUSD_RevertWhen_NewMinFeeExceedsMaxFee() external whenCallerAdmin {
        uint256 newMinFeeUSD = MAX_FEE_USD + 1;
        vm.expectRevert(
            abi.encodeWithSelector(Errors.SablierComptroller_MaxFeeUSDExceeded.selector, newMinFeeUSD, MAX_FEE_USD)
        );
        comptroller.setLockupMinFeeUSD(newMinFeeUSD);
    }

    function test_SetLockupMinFeeUSD_WhenNewMinFeeNotExceedMaxFee() external whenCallerAdmin {
        // Set the min fee USD.
        _setLockupMinFeeUSD();
    }

    function _setLockupMinFeeUSD() private {
        uint256 newMinFeeUSD = MAX_FEE_USD;

        // It should emit a {SetMinFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetLockupMinFeeUSD({ newMinFeeUSD: newMinFeeUSD, previousMinFeeUSD: LOCKUP_MIN_FEE_USD });

        comptroller.setLockupMinFeeUSD(newMinFeeUSD);

        // It should set the min USD fee.
        assertEq(comptroller.getLockupMinFeeUSD(), newMinFeeUSD, "min fee USD");
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       ORACLE
    //////////////////////////////////////////////////////////////////////////*/

    function test_SetOracle_RevertWhen_CallerNotAdmin() external {
        setMsgSender(eve);

        // It should revert.
        vm.expectRevert(abi.encodeWithSelector(Errors.CallerNotAdmin.selector, admin, eve));
        comptroller.setOracle(address(0));
    }

    function test_SetOracle_WhenNewOracleZero() external whenCallerAdmin {
        // It should emit a {SetOracle} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetOracle(admin, address(0), address(oracle));
        comptroller.setOracle(address(0));

        // It should set the oracle to zero.
        assertEq(comptroller.oracle(), address(0), "oracle after");
    }

    modifier whenNewOracleNotZero() {
        _;
    }

    function test_SetOracle_RevertWhen_NewOracleWithoutImplementation() external whenCallerAdmin whenNewOracleNotZero {
        Noop noop = new Noop();

        // It should revert.
        vm.expectRevert();
        comptroller.setOracle(address(noop));
    }

    function test_SetOracle_WhenNewOracleWithImplementation() external whenCallerAdmin whenNewOracleNotZero {
        ChainlinkOracleMock newOracleWithImpl = new ChainlinkOracleMock();

        // It should emit a {SetOracle} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit ISablierComptroller.SetOracle(admin, address(newOracleWithImpl), address(oracle));
        comptroller.setOracle(address(newOracleWithImpl));

        // It should set the oracle.
        assertEq(comptroller.oracle(), address(newOracleWithImpl), "oracle after");
    }
}
