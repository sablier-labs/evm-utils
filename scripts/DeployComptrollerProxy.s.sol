// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Options, Upgrades } from "@openzeppelin/foundry-upgrades/src/Upgrades.sol";
import { SablierComptroller } from "../src/SablierComptroller.sol";
import { BaseScript } from "../src/tests/BaseScript.sol";

contract DeployComptrollerProxy is BaseScript {
    function run() public broadcast returns (address proxy) {
        // Declare the constructor parameters of the implementation contract.
        Options memory opts;
        opts.constructorData = abi.encode(getAdmin());

        // Allow constructor in the implementation contract. See
        // https://docs.openzeppelin.com/upgrades-plugins/faq#how-can-i-disable-checks.
        opts.unsafeAllow = "constructor";

        // Declare the initializer data for the proxy.
        bytes memory initializerData = abi.encodeCall(
            SablierComptroller.initialize,
            (getAdmin(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getChainlinkOracle())
        );

        // Deploy the proxy along with the implementation and initialize the state variables.
        proxy = Upgrades.deployUUPSProxy({
            contractName: "SablierComptroller.sol:SablierComptroller",
            initializerData: initializerData,
            opts: opts
        });
    }
}
