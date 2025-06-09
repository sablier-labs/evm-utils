// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ComptrollerManager } from "src/ComptrollerManager.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract ComptrollerManager_Unit_Concrete_Test is Unit_Test {
    IComptrollerManager internal comptrollerManager;

    function setUp() public virtual override {
        Unit_Test.setUp();

        // Deploy the contracts
        comptrollerManager = new ComptrollerManager(address(comptroller));

        // Set the comptroller in the manager.
        assertEq(address(comptrollerManager.comptroller()), address(comptroller), "Comptroller not set correctly");
    }
}
