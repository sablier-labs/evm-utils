// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierComptroller } from "./ISablierComptroller.sol";

/// @title IComptrollerManager
/// @notice Contract module that provides a setter and getter for the Sablier comptroller.
interface IComptrollerManager {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the comptroller address is set by the admin.
    event SetComptroller(ISablierComptroller newComptroller, ISablierComptroller oldComptroller);

    /// @notice Emitted when the native token fees generated are transferred to the comptroller contract.
    /// @param comptroller The address of the current comptroller.
    /// @param feeAmount The amount of native tokens transferred, denoted in units of the native token's decimals.
    event TransferFeesToComptroller(ISablierComptroller indexed comptroller, uint256 feeAmount);

    /*//////////////////////////////////////////////////////////////////////////
                                READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the address of the comptroller contract.
    function comptroller() external view returns (ISablierComptroller);

    /*//////////////////////////////////////////////////////////////////////////
                              STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Sets the comptroller to a new address.
    /// @dev Emits a {SetComptroller} event.
    ///
    /// Requirements:
    /// - `msg.sender` must be the current comptroller.
    ///
    /// @param newComptroller The address of the new comptroller contract.
    function setComptroller(ISablierComptroller newComptroller) external;

    /// @notice Transfers the fees accrued to the comptroller contract.
    /// @dev Emits a {TransferFeesToComptroller} event.
    function transferFeesToComptroller() external;
}
