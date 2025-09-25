// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

library ChainId {
    /*//////////////////////////////////////////////////////////////////////////
                                     FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns `true` if the given chain ID is supported.
    function isSupported(uint64 chainId) internal pure returns (bool) {
        bool isMainnet = chainId == ABSTRACT || chainId == ARBITRUM || chainId == AVALANCHE || chainId == BASE
            || chainId == BERACHAIN || chainId == BLAST || chainId == BSC || chainId == CHILIZ || chainId == COREDAO
            || chainId == ETHEREUM || chainId == GNOSIS || chainId == HYPEREVM || chainId == LIGHTLINK || chainId == LINEA
            || chainId == MODE || chainId == MORPH || chainId == OPTIMISM || chainId == POLYGON || chainId == SCROLL
            || chainId == SEI || chainId == SOPHON || chainId == SUPERSEED || chainId == SONIC || chainId == UNICHAIN
            || chainId == XDC || chainId == ZKSYNC;

        bool isTestnet = chainId == ARBITRUM_SEPOLIA || chainId == BASE_SEPOLIA || chainId == MODE_SEPOLIA
            || chainId == OPTIMISM_SEPOLIA || chainId == SEPOLIA;

        return isMainnet || isTestnet;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                      MAINNETS
    //////////////////////////////////////////////////////////////////////////*/

    uint64 public constant ABSTRACT = 2741;
    uint64 public constant ARBITRUM = 42_161;
    uint64 public constant AVALANCHE = 43_114;
    uint64 public constant BASE = 8453;
    uint64 public constant BERACHAIN = 80_094;
    uint64 public constant BLAST = 81_457;
    uint64 public constant BSC = 56;
    uint64 public constant CHILIZ = 88_888;
    uint64 public constant COREDAO = 1116;
    uint64 public constant ETHEREUM = 1;
    uint64 public constant GNOSIS = 100;
    uint64 public constant HYPEREVM = 999;
    uint64 public constant LIGHTLINK = 1890;
    uint64 public constant LINEA = 59_144;
    uint64 public constant MODE = 34_443;
    uint64 public constant MORPH = 2818;
    uint64 public constant OPTIMISM = 10;
    uint64 public constant POLYGON = 137;
    uint64 public constant SCROLL = 534_352;
    uint64 public constant SEI = 1329;
    uint64 public constant SONIC = 146;
    uint64 public constant SOPHON = 50_104;
    uint64 public constant SUPERSEED = 5330;
    uint64 public constant TANGLE = 5845;
    uint64 public constant UNICHAIN = 130;
    uint64 public constant XDC = 50;
    uint64 public constant ZKSYNC = 324;

    /*//////////////////////////////////////////////////////////////////////////
                                      TESTNETS
    //////////////////////////////////////////////////////////////////////////*/

    uint64 public constant ARBITRUM_SEPOLIA = 421_614;
    uint64 public constant BASE_SEPOLIA = 84_532;
    uint64 public constant MODE_SEPOLIA = 919;
    uint64 public constant OPTIMISM_SEPOLIA = 11_155_420;
    uint64 public constant SEPOLIA = 11_155_111;
}
