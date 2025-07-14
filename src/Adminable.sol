// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IAdminable } from "./interfaces/IAdminable.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title Adminable
/// @notice See the documentation in {IAdminable}.
abstract contract Adminable is IAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAdminable
    address public override admin;

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if called by any account other than the admin.
    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Emits a {TransferAdmin} event.
    /// @param initialAdmin The address of the initial admin.
    constructor(address initialAdmin) {
        initializeAdmin(initialAdmin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IAdminable
    function transferAdmin(address newAdmin) public virtual override onlyAdmin {
        // Effect: update the admin.
        admin = newAdmin;

        // Log the transfer of the admin.
        emit IAdminable.TransferAdmin({ oldAdmin: msg.sender, newAdmin: newAdmin });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev An internal function to initialize the admin.
    function initializeAdmin(address initialAdmin) internal {
        admin = initialAdmin;
        emit TransferAdmin({ oldAdmin: address(0), newAdmin: initialAdmin });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev A private function is used instead of inlining this logic in a modifier because Solidity copies modifiers
    /// into every function that uses them.
    function _onlyAdmin() private view {
        if (admin != msg.sender) {
            revert Errors.CallerNotAdmin({ admin: admin, caller: msg.sender });
        }
    }
}
