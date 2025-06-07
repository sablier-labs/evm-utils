// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ComptrollerManager } from "src/ComptrollerManager.sol";
import { SablierComptroller } from "src/SablierComptroller.sol";
import { IComptrollerManager } from "src/interfaces/IComptrollerManager.sol";
import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";

import { Unit_Test } from "../../Unit.t.sol";

contract ComptrollerManager_Unit_Concrete_Test is Unit_Test {
    ISablierComptroller comptroller;
    IComptrollerManager comptrollerManager;

    function setUp() public virtual override {
        Unit_Test.setUp();

        // Deploy the contracts
        comptroller = new SablierComptroller(admin, 0, 0, 0, address(0));
        comptrollerManager = new ComptrollerManager(address(comptroller));

        // Set the comptroller in the manager.
        assertEq(address(comptrollerManager.comptroller()), address(comptroller), "Comptroller not set correctly");
    }
}
