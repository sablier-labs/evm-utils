// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { Errors } from "src/libraries/Errors.sol";
import { ComptrollerableMock } from "src/mocks/ComptrollerableMock.sol";

import { Base_Test } from "../../../Base.t.sol";

contract Constructor_Comptrollerable_Concrete_Test is Base_Test {
    function test_RevertWhen_ComptrollerZeroAddress() external {
        vm.expectRevert(Errors.Comptrollerable_ZeroAddress.selector);
        new ComptrollerableMock(address(0));
    }

    function test_Constructor() external view whenComptrollerNotZeroAddress {
        // Assert the state variables.
        assertEq(address(comptrollerableMock.comptroller()), address(comptroller), "comptroller");
    }
}
