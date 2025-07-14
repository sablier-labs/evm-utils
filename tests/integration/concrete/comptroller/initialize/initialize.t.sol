// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import { ISablierComptroller } from "src/interfaces/ISablierComptroller.sol";

import { Base_Test } from "tests/Base.t.sol";

contract Initialize_Comptroller_Concrete_Test is Base_Test {
    ISablierComptroller internal comptrollerImpl;

    function setUp() public override {
        Base_Test.setUp();

        comptrollerImpl = ISablierComptroller(getComptrollerImplAddress());
    }

    function test_RevertWhen_CalledOnImplementation() external {
        // It should revert.
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        comptrollerImpl.initialize(admin, AIRDROP_MIN_FEE_USD, FLOW_MIN_FEE_USD, LOCKUP_MIN_FEE_USD, address(oracle));
    }

    function test_RevertGiven_Initialized() external whenCalledOnProxy {
        // It should revert.
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        comptroller.initialize(admin, AIRDROP_MIN_FEE_USD, FLOW_MIN_FEE_USD, LOCKUP_MIN_FEE_USD, address(oracle));
    }

    function test_GivenNotInitialized() external whenCalledOnProxy {
        // Deploy a comptroller proxy without initializing it.
        ISablierComptroller uninitializedComptroller =
            ISablierComptroller(address(new ERC1967Proxy({ implementation: address(comptrollerImpl), _data: "" })));

        // It should initialize the states.
        uninitializedComptroller.initialize(
            admin, AIRDROP_MIN_FEE_USD, FLOW_MIN_FEE_USD, LOCKUP_MIN_FEE_USD, address(oracle)
        );

        assertEq(uninitializedComptroller.admin(), admin, "admin");
        assertEq(uninitializedComptroller.MAX_FEE_USD(), MAX_FEE_USD, "max fee USD");
        assertEq(uninitializedComptroller.oracle(), address(oracle), "oracle");
        assertEq(
            uninitializedComptroller.getMinFeeUSD(ISablierComptroller.Protocol.Airdrops),
            AIRDROP_MIN_FEE_USD,
            "get min fee USD Airdrops"
        );
        assertEq(
            uninitializedComptroller.getMinFeeUSD(ISablierComptroller.Protocol.Flow),
            FLOW_MIN_FEE_USD,
            "get min fee USD Flow"
        );
        assertEq(
            uninitializedComptroller.getMinFeeUSD(ISablierComptroller.Protocol.Lockup),
            LOCKUP_MIN_FEE_USD,
            "get min fee USD Lockup"
        );
    }
}
