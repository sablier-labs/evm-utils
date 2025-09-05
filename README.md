# Sablier EVM Utils [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![Discord][discord-badge]][discord]

[gha]: https://github.com/sablier-labs/evm-utils/actions
[gha-badge]: https://github.com/sablier-labs/evm-utils/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/sablier-labs/evm-utils
[codecov-badge]: https://codecov.io/gh/sablier-labs/evm-utils/graph/badge.svg?token=iWxbU4RAsi
[discord]: https://discord.gg/bSwRCwWRsT
[discord-badge]: https://img.shields.io/discord/659709894315868191
[foundry]: https://getfoundry.sh
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

This repository contains the following two sets of contracts:

### Sablier comptroller

Its a standalone contract with the following responsibilities:

- Handles state variables, setters and getters, and calculations using external oracles to manage fees across all the
  Sablier protocols.
- Authority over admin functions across Sablier protocols.

### Utility contracts

Its a collection of smart contracts used across various Sablier Solidity projects. The motivation behind this is to
reduce code duplication. The following projects imports these contracts:

- [Sablier Airdrops](https://github.com/sablier-labs/airdrops/)
- [Sablier Flow](https://github.com/sablier-labs/flow/)
- [Sablier Lockup](https://github.com/sablier-labs/lockup/)

In-depth documentation is available at [docs.sablier.com](https://docs.sablier.com).

## Repository Structure

This repo contains the following subdirectories:

- [`src/interfaces`](./src/interfaces/): Interfaces to be used by external projects.
- [`src/mocks`](./src/mocks/): Mock contracts used by external projects in tests.
- [`src/tests`](./src/tests/): Helper contracts used by external projects in tests and deployment scripts.

## Install

### Node.js

This is the recommended approach.

Install using your favorite package manager, e.g., with Bun:

```shell
bun add @sablier/evm-utils
```

### Git Submodules

This installation method is not recommended, but it is available for those who prefer it.

First, install the submodule using Forge:

```shell
forge install --no-commit sablier-labs/evm-utils
```

## Usage

```solidity
import { Adminable } from "@sablier/evm-utils/src/Adminable.sol";
import { Batch } from "@sablier/evm-utils/src/Batch.sol";
import { NoDelegateCall } from "@sablier/evm-utils/src/NoDelegateCall.sol";

contract MyContract is Adminable, Batch, NoDelegateCall {
    constructor(address initialAdmin) Adminable(initialAdmin) { }

    // Use the `noDelegateCall` modifier to prevent delegate calls.
    function foo() public noDelegateCall { }

    // Use the `onlyAdmin` modifier to restrict access to the admin.
    function editFee(uint256 newFee) public onlyAdmin { }
}
```

## Contributing

Feel free to dive in! [Open](https://github.com/sablier-labs/evm-utils/issues/new) an issue,
[start](https://github.com/sablier-labs/evm-utils/discussions/new) a discussion or submit a PR. For any informal
concerns or feedback, please join our [Discord server](https://discord.gg/bSwRCwWRsT).

For guidance on how to create PRs, see the [CONTRIBUTING](./CONTRIBUTING.md) guide.

## License

See [LICENSE.md](./LICENSE.md).
