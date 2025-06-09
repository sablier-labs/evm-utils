// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { StdAssertions } from "forge-std/src/StdAssertions.sol";
import { BaseTest } from "src/tests/BaseTest.sol";
import { Modifiers } from "./utils/Modifiers.sol";

abstract contract Unit_Test is BaseTest, Modifiers, StdAssertions {
    address internal accountant;
    address internal alice;
    address internal eve;
    address[] internal noSpenders;

    function setUp() public virtual override {
        BaseTest.setUp();

        accountant = createUser("accountant", noSpenders);
        alice = createUser("alice", noSpenders);
        eve = createUser("eve", noSpenders);

        setMsgSender(admin);
    }
}
