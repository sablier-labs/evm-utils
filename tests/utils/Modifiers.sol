// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

abstract contract Modifiers {
    modifier whenAccountNotAdmin() {
        _;
    }

    modifier whenCallerAdmin() {
        _;
    }

    modifier whenCallerNotAdmin() {
        _;
    }

    modifier whenFunctionExists() {
        _;
    }

    modifier whenNewAdminNotSameAsCurrentAdmin() {
        _;
    }

    modifier whenNonStateChangingFunction() {
        _;
    }

    modifier whenNotPayable() {
        _;
    }

    modifier whenPayable() {
        _;
    }

    modifier whenStateChangingFunction() {
        _;
    }
}
