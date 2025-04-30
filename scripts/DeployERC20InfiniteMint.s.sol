// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ERC20InfiniteMint } from "src/mocks/erc20/ERC20InfiniteMint.sol";
import { BaseScript } from "src/tests/BaseScript.sol";

contract DeployERC20InfiniteMint is BaseScript {
    function run() public broadcast returns (ERC20InfiniteMint token) {
        token = new ERC20InfiniteMint();
    }
}
