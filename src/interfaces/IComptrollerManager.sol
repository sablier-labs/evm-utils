// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ISablierComptroller } from "./ISablierComptroller.sol";

/// @title IComptrollerManager
/// @notice Contract for managing the Sablier protocol's comptroller.
interface IComptrollerManager {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the comptroller address is set by the admin.
    event SetComptroller(address newComptroller, address previousComptroller);

    /*//////////////////////////////////////////////////////////////////////////
                                READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the address of the comptroller contract.
    /// @dev The comptroller is a contract that manages the Sablier protocol's fees.
    function comptroller() external view returns (ISablierComptroller);

    /*//////////////////////////////////////////////////////////////////////////
                              STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Sets the address of the comptroller contract.
    /// @dev Emits a {SetComptroller} event.
    ///
    /// Requirements:
    /// - `msg.sender` must be the current comptroller.
    ///
    /// @param newComptroller The address of the new comptroller contract.
    function setComptroller(address newComptroller) external;
}
