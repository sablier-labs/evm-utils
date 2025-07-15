// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { SablierComptroller } from "../src/SablierComptroller.sol";
import { BaseScript } from "../src/tests/BaseScript.sol";

contract DeployComptroller is BaseScript {
    function run() public broadcast returns (SablierComptroller comptrollerImpl, address comptrollerProxy) {
        // Deploy the comptroller implementation.
        comptrollerImpl = new SablierComptroller(
            getAdmin(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getChainlinkOracle()
        );

        // Deploy the comptroller proxy and initialize the state variables.
        // Note: This should be done only once when a new proxy is deployed. In the future, this must be changed to
        // handle the {upgradeToAndCall} function to update the new comptroller implementation.
        comptrollerProxy = address(
            new ERC1967Proxy({
                implementation: address(comptrollerImpl),
                _data: abi.encodeCall(
                    SablierComptroller.initialize,
                    (getAdmin(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getInitialMinFeeUSD(), getChainlinkOracle())
                )
            })
        );
    }
}
