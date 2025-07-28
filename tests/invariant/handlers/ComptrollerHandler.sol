// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.26;

import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { Adminable } from "src/Adminable.sol";
import { SablierComptroller } from "src/SablierComptroller.sol";

contract ComptrollerHandler {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    address public comptroller;

    mapping(string functionName => uint256 count) public calls;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address comptroller_) {
        comptroller = comptroller_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      HANDLERS
    //////////////////////////////////////////////////////////////////////////*/

    function initialize(address newAdmin) external {
        (bool success,) =
            comptroller.call(abi.encodeCall(SablierComptroller.initialize, (newAdmin, 0, 0, 0, address(0))));

        if (success) calls["initialize"]++;
    }

    function transferAdmin(address newAdmin) external {
        (bool success,) = comptroller.call(abi.encodeCall(Adminable.transferAdmin, (newAdmin)));

        if (success) calls["transferAdmin"]++;
    }

    function upgradeToAndCall(address newAdmin) external {
        // Deploy a new comptroller.
        address newImplementation = address(new SablierComptroller(newAdmin));

        // Upgrade to the new comptroller.
        (bool success,) = comptroller.call(abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (newImplementation, "")));

        if (success) calls["upgradeToAndCall"]++;
    }
}
