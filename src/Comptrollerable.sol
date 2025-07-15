// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierComptroller } from "./interfaces/ISablierComptroller.sol";
import { IComptrollerable } from "./interfaces/IComptrollerable.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title Comptrollerable
/// @notice See the documentation in {IComptrollerable}.
abstract contract Comptrollerable is IComptrollerable {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IComptrollerable
    ISablierComptroller public override comptroller;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if called by any account other than the comptroller.
    modifier onlyComptroller() {
        _checkComptroller();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialComptroller The address of the initial comptroller contract.
    constructor(address initialComptroller) {
        // Define the minimal interface ID required by the contracts inherited from {Comptrollerable}.
        bytes4 initialMInimalInterfaceId = ISablierComptroller.calculateMinFeeWeiFor.selector
            ^ ISablierComptroller.convertUSDFeeToWei.selector ^ ISablierComptroller.execute.selector
            ^ ISablierComptroller.getMinFeeUSDFor.selector;

        // Set the initial comptroller.
        _setComptroller({
            interfaceId: initialMInimalInterfaceId,
            previousComptroller: ISablierComptroller(address(0)),
            newComptroller: ISablierComptroller(initialComptroller)
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IComptrollerable
    function setComptroller(ISablierComptroller newComptroller) external override onlyComptroller {
        // Checks and Effects: set the new comptroller.
        _setComptroller({
            interfaceId: comptroller.MINIMAL_INTERFACE_ID(),
            previousComptroller: comptroller,
            newComptroller: newComptroller
        });
    }

    /// @inheritdoc IComptrollerable
    function transferFeesToComptroller() external override {
        uint256 feeAmount = address(this).balance;

        // Interaction: transfer the fees to the comptroller.
        (bool success,) = address(comptroller).call{ value: feeAmount }("");

        // Dummy assignment to silence the compiler warning, because comptroller is expected to implement `receive()`
        // function.
        success;

        // Log the fee transfer.
        emit IComptrollerable.TransferFeesToComptroller(comptroller, feeAmount);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the user-facing functions that call this private function.
    function _checkComptroller() private view {
        if (msg.sender != address(comptroller)) {
            revert Errors.Comptrollerable_CallerNotComptroller(address(comptroller), msg.sender);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          PRIVATE STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the user-facing functions that call this private function.
    function _setComptroller(
        bytes4 interfaceId,
        ISablierComptroller previousComptroller,
        ISablierComptroller newComptroller
    )
        private
    {
        // Check: the new comptroller supports the minimal interface ID.
        if (!newComptroller.supportsInterface(interfaceId)) {
            revert Errors.SablierComptroller_UnsupportedInterfaceId({
                previousComptroller: address(previousComptroller),
                newComptroller: address(newComptroller),
                minimalInterfaceId: interfaceId
            });
        }

        // Effect: set the new comptroller.
        comptroller = newComptroller;

        // Log the change.
        emit SetComptroller(previousComptroller, newComptroller);
    }
}
