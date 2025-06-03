// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IRoleAdminable } from "./IRoleAdminable.sol";

interface IComptroller is IRoleAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                     DATA-TYPES
    //////////////////////////////////////////////////////////////////////////*/

    enum CustomeFeeRole {
        CampaignCreator,
        Sender
    }

    /// @notice Struct encapsulating the parameters of a custom USD fee.
    /// @param enabled Whether the fee is enabled. If false, the min USD fee will apply instead.
    /// @param fee The fee amount.
    struct CustomFeeUSD {
        bool enabled;
        uint256 fee;
        CustomeFeeRole role;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the accrued fees are collected.
    event CollectFees(address indexed admin, address indexed feeRecipient, uint256 feeAmount);

    /// @notice Emitted when the admin resets the custom USD fee for the provided campaign creator to the min fee.
    event DisableCustomFeeUSD(address indexed admin, address indexed user);

    /// @notice Emitted when the admin sets a custom USD fee for the provided campaign creator.
    event SetCustomFeeUSD(address indexed admin, address indexed user, uint256 customFeeUSD);

    /// @notice Emitted when the min USD fee is set by the admin.
    event SetMinFeeUSD(address indexed admin, uint256 newMinFeeUSD, uint256 previousMinFeeUSD);

    /// @notice Emitted when the oracle contract address is set by the admin.
    event SetOracle(address indexed admin, address newOracle, address previousOracle);

    /*//////////////////////////////////////////////////////////////////////////
                                READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Retrieves the maximum USD fee that can be set for claiming an airdrop or withdrawing from a stream fee.
    /// @dev The returned value is 100e8, which is equivalent to $100.
    function MAX_FEE_USD() external view returns (uint256);

    /// @notice Calculates the min fee in wei, using the state variable {_minFeeUSD}, required to either claim an
    /// airdrop or to withdraw from a stream.
    /// @dev Refer to {calculateMinFeeWei(uint256 minFeeUSD)} for more details on how the fee is calculated.
    function calculateMinFeeWei() external view returns (uint256);

    /// @notice Calculates the min fee in wei required to either claim an airdrop or to withdraw from a stream.
    ///
    /// The price is considered to be 0 if:
    /// 1. The oracle is not set.
    /// 2. The min USD fee is 0.
    /// 3. The oracle price is ≤ 0.
    /// 4. The oracle's update timestamp is in the future.
    /// 5. The oracle price hasn't been updated in the last 24 hours.
    ///
    /// @param minFeeUSD The min USD fee, denominated in Chainlink's 8-decimal format for USD prices, where 1e8 is $1.
    /// @return The min fee in wei, denominated in 18 decimals (1e18 = 1 native token).
    function calculateMinFeeWei(uint256 minFeeUSD) external view returns (uint256);

    function calculateMinFeeWeiForSender(address sender) external view returns (uint256);

    /// @notice Determines the min USD fee applicable for the provided stream sender. By default, the min USD fee is
    /// applied unless there is a custom USD fee set.
    /// @param user The address of the user.
    /// @return The min USD fee, denominated in Chainlink's 8-decimal format for USD prices.
    function getMinFeeUSDForSender(address user) external view returns (uint256);

    /// @notice Determines the min USD fee applicable for the provided sender. By default, the min USD fee is
    /// applied unless there is a custom USD fee set.
    /// @param user The address of the user.
    /// @return The min USD fee, denominated in Chainlink's 8-decimal format for USD prices.
    function getMinFeeUSDForCampaignCreator(address user) external view returns (uint256);

    /// @notice Retrieves the min USD fee required to claim the airdrop, paid in the native token of the chain, e.g.,
    /// ETH for Ethereum Mainnet.
    /// @dev The fee is denominated in Chainlink's 8-decimal format for USD prices, where 1e8 is $1.
    function getMinFeeUSD() external view returns (uint256);

    /// @notice Retrieves the oracle contract address, which provides price data for the native token.
    function oracle() external view returns (address);

    /*//////////////////////////////////////////////////////////////////////////
                              STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Collects the accrued fees. If `feeRecipient` is a contract, it must be able to receive native tokens,
    /// e.g., ETH for Ethereum Mainnet.
    ///
    /// @dev Emits a {CollectFees} event.
    ///
    /// Requirements:
    /// - If `msg.sender` has neither the {IRoleAdminable.FEE_COLLECTOR_ROLE} role nor is the contract admin, then
    /// `feeRecipient` must be the admin address.
    ///
    /// @param feeRecipient The address where the fees will be collected.
    function collectFees(address feeRecipient) external;

    /// @notice Disables the custom USD fee for the provided campaign creator, who will now pay the min USD fee.
    /// @dev Emits a {DisableCustomFee} event.
    ///
    /// Notes:
    /// - The min fee will apply only to future campaigns. Fees for past campaigns remain unchanged.
    ///
    /// Requirements:
    /// - `msg.sender` must be either the admin or have the {IRoleAdminable.FEE_MANAGEMENT_ROLE} role.
    ///
    /// @param user The user to disable the custom fee for.
    function disableCustomFeeUSD(address user) external;

    /// @notice Sets a custom USD fee for the provided campaign creator.
    /// @dev Emits a {SetCustomFee} event.
    ///
    /// Notes:
    /// - The custom USD fee will apply only to future campaigns. Fees for past campaigns remain unchanged.
    ///
    /// Requirements:
    /// - `msg.sender` must be either the admin or have the {IRoleAdminable.FEE_MANAGEMENT_ROLE} role.
    ///
    /// @param user The user for whom the fee is set.
    /// @param customFeeUSD The custom USD fee to set, denominated in 8 decimals.
    function setCustomFeeUSD(address user, uint256 customFeeUSD) external;

    /// @notice Sets the min USD fee for upcoming campaigns.
    /// @dev Emits a {SetMinFeeUSD} event.
    ///
    /// Notes:
    /// - The new USD fee will apply only to future campaigns. Fees for past campaigns remain unchanged.
    ///
    /// Requirements:
    /// - `msg.sender` must be either the admin or have the {IRoleAdminable.FEE_MANAGEMENT_ROLE} role.
    ///
    /// @param newMinFeeUSD The custom USD fee to set, denominated in 8 decimals.
    function setMinFeeUSD(uint256 newMinFeeUSD) external;

    /// @notice Sets the oracle contract address. The zero address can be used to disable the oracle.
    /// @dev Emits a {SetOracle} event.
    ///
    /// Requirements:
    /// - `msg.sender` must be the admin.
    /// - If `newOracle` is not the zero address, the call to it must not fail.
    ///
    /// @param newOracle The new oracle contract address. It can be the zero address.
    function setOracle(address newOracle) external;
}
