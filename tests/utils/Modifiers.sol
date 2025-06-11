// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { BaseTest } from "src/tests/BaseTest.sol";
import { Users } from "./Types.sol";

abstract contract Modifiers is BaseTest {
    Users private users;

    function setUsers(Users memory users_) internal {
        users = users_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       GIVEN
    //////////////////////////////////////////////////////////////////////////*/

    modifier givenOracleNotZero() {
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        WHEN
    //////////////////////////////////////////////////////////////////////////*/

    modifier whenAccountHasRole() {
        _;
    }

    modifier whenAccountNotAdmin() {
        _;
    }

    modifier whenAccountNotHaveRole() {
        _;
    }

    modifier whenCallerAdmin() {
        setMsgSender(users.admin);
        _;
    }

    modifier whenCallerNotAdmin() {
        _;
    }

    modifier whenCallerCurrentComptroller() {
        setMsgSender(address(comptroller));
        _;
    }

    modifier whenCallerWithoutFeeCollectorRole() {
        _;
    }

    modifier whenFeeRecipientContract() {
        _;
    }

    modifier whenFunctionExists() {
        _;
    }

    modifier whenMinFeeUSDNotZero() {
        _;
    }

    modifier whenNewAdminNotSameAsCurrentAdmin() {
        _;
    }

    modifier whenNewFeeNotExceedMaxFee() {
        _;
    }

    modifier whenNewOracleNotZero() {
        _;
    }

    modifier whenNonStateChangingFunction() {
        _;
    }

    modifier whenNotPayable() {
        _;
    }

    modifier whenOraclePriceNotOutdated() {
        _;
    }

    modifier whenOraclePriceNotZero() {
        _;
    }

    modifier whenOracleUpdatedTimeNotInFuture() {
        _;
    }

    modifier whenPayable() {
        _;
    }

    modifier whenStateChangingFunction() {
        _;
    }

    modifier whenTargetContract() {
        _;
    }

    modifier whenTheCallCallReverts() {
        _;
    }
}
