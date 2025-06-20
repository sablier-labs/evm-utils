// SPDX-License-Identifier: GPL-3.0-or-later
// solhint-disable code-complexity
// solhint-disable no-console
pragma solidity >=0.8.22;

import { Script } from "forge-std/src/Script.sol";
import { stdJson } from "forge-std/src/StdJson.sol";
import { ChainIds } from "./ChainIds.sol";

abstract contract BaseScript is Script {
    using stdJson for string;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev The address of the default Sablier admin.
    address public constant DEFAULT_SABLIER_ADMIN = 0xb1bEF51ebCA01EB12001a639bDBbFF6eEcA12B9F;

    /// @dev The salt used for deterministic deployments.
    bytes32 public immutable SALT;

    /// @dev Included to enable compilation of the script without a $MNEMONIC environment variable.
    string public constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

    /// @dev The address of the transaction broadcaster.
    address public broadcaster;

    /// @dev Used to derive the broadcaster's address if $ETH_FROM is not defined.
    string public mnemonic;

    /*//////////////////////////////////////////////////////////////////////////
                                      MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Initializes the transaction broadcaster like this:
    ///
    /// - If $ETH_FROM is defined, use it.
    /// - Otherwise, derive the broadcaster address from $MNEMONIC.
    /// - If $MNEMONIC is not defined, default to a test mnemonic.
    ///
    /// The use case for $ETH_FROM is to specify the broadcaster key and its address via the command line.
    constructor() {
        address from = vm.envOr({ name: "ETH_FROM", defaultValue: address(0) });
        if (from != address(0)) {
            broadcaster = from;
        } else {
            mnemonic = vm.envOr({ name: "MNEMONIC", defaultValue: TEST_MNEMONIC });
            (broadcaster,) = deriveRememberKey({ mnemonic: mnemonic, index: 0 });
        }

        // Construct the salt for deterministic deployments.
        SALT = constructCreate2Salt();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                        HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the Chainlink oracle for the supported chains. These addresses can be verified on
    /// https://docs.chain.link/data-feeds/price-feeds/addresses.
    /// @dev If the chain does not have a Chainlink oracle, return 0.
    function chainlinkOracle() public view returns (address addr) {
        if (block.chainid == ChainIds.MAINNET) return 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        if (block.chainid == ChainIds.ARBITRUM) return 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
        if (block.chainid == ChainIds.AVALANCHE) return 0x0A77230d17318075983913bC2145DB16C7366156;
        if (block.chainid == ChainIds.BASE) return 0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70;
        if (block.chainid == ChainIds.BSC) return 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
        if (block.chainid == ChainIds.GNOSIS) return 0x678df3415fc31947dA4324eC63212874be5a82f8;
        if (block.chainid == ChainIds.LINEA) return 0x3c6Cd9Cc7c7a4c2Cf5a82734CD249D7D593354dA;
        if (block.chainid == ChainIds.OPTIMISM) return 0x13e3Ee699D1909E989722E753853AE30b17e08c5;
        if (block.chainid == ChainIds.POLYGON) return 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
        if (block.chainid == ChainIds.SCROLL) return 0x6bF14CB0A831078629D993FDeBcB182b21A8774C;

        // Return address zero for unsupported chain.
        return address(0);
    }

    function comptrollerAddress() public view returns (address) {
        // TODO: Update the addresses to the actual Sablier Comptroller addresses for each chain.
        // Mainnets
        if (block.chainid == ChainIds.MAINNET) return address(0xCAFE);
        if (block.chainid == ChainIds.ARBITRUM) return address(0xCAFE);
        if (block.chainid == ChainIds.AVALANCHE) return address(0xCAFE);
        if (block.chainid == ChainIds.BASE) return address(0xCAFE);
        if (block.chainid == ChainIds.BERACHAIN) return address(0xCAFE);
        if (block.chainid == ChainIds.BLAST) return address(0xCAFE);
        if (block.chainid == ChainIds.BSC) return address(0xCAFE);
        if (block.chainid == ChainIds.CHILIZ) return address(0xCAFE);
        if (block.chainid == ChainIds.COREDAO) return address(0xCAFE);
        if (block.chainid == ChainIds.FORM) return address(0xCAFE);
        if (block.chainid == ChainIds.GNOSIS) return address(0xCAFE);
        if (block.chainid == ChainIds.LIGHTLINK) return address(0xCAFE);
        if (block.chainid == ChainIds.LINEA) return address(0xCAFE);
        if (block.chainid == ChainIds.MODE) return address(0xCAFE);
        if (block.chainid == ChainIds.MORPH) return address(0xCAFE);
        if (block.chainid == ChainIds.OPTIMISM) return address(0xCAFE);
        if (block.chainid == ChainIds.POLYGON) return address(0xCAFE);
        if (block.chainid == ChainIds.SCROLL) return address(0xCAFE);
        if (block.chainid == ChainIds.SUPERSEED) return address(0xCAFE);
        if (block.chainid == ChainIds.TAIKO) return address(0xCAFE);
        if (block.chainid == ChainIds.XDC) return address(0xCAFE);

        // Testnets
        if (block.chainid == ChainIds.SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.ARBITRUM_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.BASE_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.BLAST_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.LINEA_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.MODE_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.MONAD_TESTNET) return address(0xCAFE);
        if (block.chainid == ChainIds.OPTIMISM_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.SUPERSEED_SEPOLIA) return address(0xCAFE);
        if (block.chainid == ChainIds.TAIKO_HEKLA) return address(0xCAFE);

        // Return address zero for unsupported chain.
        return address(0);
    }

    /// @dev The presence of the salt instructs Forge to deploy contracts via this deterministic CREATE2 factory:
    /// https://github.com/Arachnid/deterministic-deployment-proxy
    ///
    /// Notes:
    /// - The salt format is "ChainID <chainid>, Version <version>".
    function constructCreate2Salt() public view virtual returns (bytes32) {
        string memory chainId = vm.toString(block.chainid);
        string memory version = getVersion();
        string memory create2Salt = string.concat("ChainID ", chainId, ", Version ", version);
        return bytes32(abi.encodePacked(create2Salt));
    }

    /// @dev The version is obtained from `package.json`.
    function getVersion() public view virtual returns (string memory) {
        string memory json = vm.readFile("package.json");
        return json.readString(".version");
    }

    /// @notice Returns the initial min USD fee as $1. If the chain does not have Chainlink, return 0.
    function initialMinFeeUSD() public view returns (uint256) {
        if (chainlinkOracle() != address(0)) {
            return 1e8;
        }
        return 0;
    }

    /// @notice Returns the protocol admin address for the current chain.
    /// @dev The chains listed below have multisig, otherwise, the default admin is used.
    function protocolAdmin() public view returns (address) {
        if (block.chainid == ChainIds.MAINNET) return 0x79Fb3e81aAc012c08501f41296CCC145a1E15844;
        if (block.chainid == ChainIds.ARBITRUM) return 0xF34E41a6f6Ce5A45559B1D3Ee92E141a3De96376;
        if (block.chainid == ChainIds.AVALANCHE) return 0x4735517616373c5137dE8bcCDc887637B8ac85Ce;
        if (block.chainid == ChainIds.BASE) return 0x83A6fA8c04420B3F9C7A4CF1c040b63Fbbc89B66;
        if (block.chainid == ChainIds.BSC) return 0x6666cA940D2f4B65883b454b7Bc7EEB039f64fa3;
        if (block.chainid == ChainIds.GNOSIS) return 0x72ACB57fa6a8fa768bE44Db453B1CDBa8B12A399;
        if (block.chainid == ChainIds.LINEA) return 0x72dCfa0483d5Ef91562817C6f20E8Ce07A81319D;
        if (block.chainid == ChainIds.OPTIMISM) return 0x43c76FE8Aec91F63EbEfb4f5d2a4ba88ef880350;
        if (block.chainid == ChainIds.POLYGON) return 0x40A518C5B9c1d3D6d62Ba789501CE4D526C9d9C6;
        if (block.chainid == ChainIds.SCROLL) return 0x0F7Ad835235Ede685180A5c611111610813457a9;

        // Return the default Sablier admin otherwise.
        return DEFAULT_SABLIER_ADMIN;
    }
}
