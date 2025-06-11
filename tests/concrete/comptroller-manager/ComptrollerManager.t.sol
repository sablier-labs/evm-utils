// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ComptrollerManagerMock } from "src/mocks/ComptrollerManagerMock.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract ComptrollerManager_Unit_Concrete_Test is Unit_Test {
    IComptrollerManager internal comptrollerManager;

    function setUp() public virtual override {
        Unit_Test.setUp();

        // Deploy the mock contract.
        comptrollerManager = new ComptrollerManagerMock(address(comptroller));

        setMsgSender(address(comptroller));
    }

    function test_Constructor() public view {
        // Set the comptroller in the manager.
        assertEq(address(comptrollerManager.comptroller()), address(comptroller), "comptroller");
    }
}
