// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

/// @notice A mock that returns false on {supportsInterface}.
contract ComptrollerWithoutCoreInterfaceId {
    constructor() { }

    function supportsInterface(bytes4) public view virtual returns (bool) { }
}
