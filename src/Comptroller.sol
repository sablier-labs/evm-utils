// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { Errors } from "./libraries/Errors.sol";
import { IComptroller } from "./interfaces/IComptroller.sol";
import { RoleAdminable } from "./RoleAdminable.sol";

contract Comptroller is IComptroller, RoleAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IComptroller
    uint256 public constant override MAX_FEE_USD = 100e8;

    /// @dev The minimum USD fee charged for withdrawing from a stream.
    uint256 private _minFeeUSD;

    /// @inheritdoc IComptroller
    address public override oracle;

    /// @dev A mapping of custom fees mapped by campaign creator addresses.
    mapping(address campaignCreator => IComptroller.CustomFeeUSD customFeeUSD) private _campaignCreatorCustomFeesUSD;

    /// @dev A mapping of custom fees mapped by campaign sender addresses.
    mapping(address sender => IComptroller.CustomFeeUSD customFeeUSD) private _senderCustomFeesUSD;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialAdmin The address of the initial contract admin.
    /// @param initialMinFeeUSD The initial min USD fee charged.
    /// @param initialOracle The initial oracle contract address.
    constructor(address initialAdmin, uint256 initialMinFeeUSD, address initialOracle) RoleAdminable(initialAdmin) {
        _minFeeUSD = initialMinFeeUSD;

        if (initialOracle != address(0)) {
            _setOracle(initialOracle);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  RECEIVE FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev We need to receive native tokens.
    receive() external payable { }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IComptroller
    function calculateMinFeeWei() external view override returns (uint256) {
        return _calculateMinFeeWei(_minFeeUSD);
    }

    /// @inheritdoc IComptroller
    function calculateMinFeeWei(uint256 minFeeUSD) external view override returns (uint256) {
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc IComptroller
    function calculateMinFeeWeiForSender(address sender) external view override returns (uint256) {
        // Check: if the sender has a custom fee, use it; otherwise, use the min fee.
        uint256 minFeeUSD = _minFeeUSDFor(sender);
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc IComptroller
    function getMinFeeUSD() external view override returns (uint256) {
        return _minFeeUSD;
    }

    /// @inheritdoc IComptroller
    function getMinFeeUSDFor(address user) external view returns (uint256) {
        return _minFeeUSDFor(user);
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IComptroller
    function collectFees(address feeRecipient) external override {
        // Check: if `msg.sender` has neither the {RoleAdminable.FEE_COLLECTOR_ROLE} role nor is the contract admin,
        // `feeRecipient` must be the admin address.
        bool hasRoleOrIsAdmin = _hasRoleOrIsAdmin({ role: FEE_COLLECTOR_ROLE, account: msg.sender });
        if (!hasRoleOrIsAdmin && feeRecipient != admin) {
            revert Errors.Comptroller_FeeRecipientNotAdmin({ feeRecipient: feeRecipient, admin: admin });
        }

        uint256 feeAmount = address(this).balance;

        // Effect: transfer the fees to the fee recipient.
        (bool success,) = feeRecipient.call{ value: feeAmount }("");

        // Revert if the call failed.
        if (!success) {
            revert Errors.Comptroller_FeeTransferFailed(feeRecipient, feeAmount);
        }

        // Log the fee withdrawal.
        emit CollectFees(admin, feeRecipient, feeAmount);
    }

    /// @inheritdoc IComptroller
    function disableCustomFeeUSD(address user) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        delete _customFeesUSD[user];

        // Log the reset.
        emit DisableCustomFeeUSD(admin, user);
    }

    /// @inheritdoc IComptroller
    function setCustomFeeUSD(address user, uint256 customFeeUSD) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        IComptroller.CustomFeeUSD storage customFee = _customFeesUSD[user];

        // Check: the new fee is not greater than the maximum allowed.
        if (customFeeUSD > MAX_FEE_USD) {
            revert Errors.Comptroller_MaxFeeUSDExceeded(customFeeUSD, MAX_FEE_USD);
        }

        // Effect: enable the custom fee for the user if it is not already enabled.
        if (!customFee.enabled) {
            customFee.enabled = true;
        }

        // Effect: update the custom fee for the provided campaign creator.
        customFee.fee = customFeeUSD;

        // Log the update.
        emit SetCustomFeeUSD({ admin: admin, user: user, customFeeUSD: customFeeUSD });
    }

    /// @inheritdoc IComptroller
    function setMinFeeUSD(uint256 newMinFeeUSD) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        // Check: the new fee is not greater than the maximum allowed.
        if (newMinFeeUSD > MAX_FEE_USD) {
            revert Errors.Comptroller_MaxFeeUSDExceeded(newMinFeeUSD, MAX_FEE_USD);
        }

        // Effect: update the min USD fee.
        uint256 currentMinFeeUSD = _minFeeUSD;
        _minFeeUSD = newMinFeeUSD;

        // Log the update.
        emit SetMinFeeUSD({ admin: admin, newMinFeeUSD: newMinFeeUSD, previousMinFeeUSD: currentMinFeeUSD });
    }

    /// @inheritdoc IComptroller
    function setOracle(address newOracle) external override onlyAdmin {
        address currentOracle = oracle;

        // Effects: set the new oracle.
        _setOracle(newOracle);

        // Log the update.
        emit SetOracle({ admin: msg.sender, newOracle: newOracle, previousOracle: currentOracle });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _minFeeUSDFor(address user) internal view returns (uint256) {
        IComptroller.CustomFeeUSD memory customFee = _customFeesUSD[user];
        return customFee.enabled ? customFee.fee : _minFeeUSD;
    }

    /*//////////////////////////////////////////////////////////////////////////
                          PRIVATE STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _calculateMinFeeWei(uint256 minFeeUSD) private view returns (uint256) {
        // If the oracle is not set, return 0.
        if (oracle == address(0)) {
            return 0;
        }

        // If the min USD fee is 0, skip the calculations.
        if (minFeeUSD == 0) {
            return 0;
        }

        // Interactions: query the oracle price and the time at which it was updated.
        (, int256 price,, uint256 updatedAt,) = AggregatorV3Interface(oracle).latestRoundData();

        // If the price is not greater than 0, skip the calculations.
        if (price <= 0) {
            return 0;
        }

        // Due to reorgs and latency issues, the oracle can have an `updatedAt` timestamp that is in the future. In
        // this case, we ignore the price and return 0.
        if (block.timestamp < updatedAt) {
            return 0;
        }

        // If the oracle hasn't been updated in the last 24 hours, we ignore the price and return 0. This is a safety
        // check to avoid using outdated prices.
        unchecked {
            if (block.timestamp - updatedAt > 24 hours) {
                return 0;
            }
        }

        // Interactions: query the oracle decimals.
        uint8 oracleDecimals = AggregatorV3Interface(oracle).decimals();

        // Adjust the price so that it has 8 decimals.
        uint256 price8D;
        if (oracleDecimals == 8) {
            price8D = uint256(price);
        } else if (oracleDecimals < 8) {
            price8D = uint256(price) * 10 ** (8 - oracleDecimals);
        } else {
            price8D = uint256(price) / 10 ** (oracleDecimals - 8);
        }

        // Multiply by 10^18 because the native token is assumed to have 18 decimals.
        return minFeeUSD * 1e18 / price8D;
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _setOracle(address newOracle) private {
        // Check: oracle implements the `latestRoundData` function.
        if (newOracle != address(0)) {
            AggregatorV3Interface(newOracle).latestRoundData();
        }

        // Effect: update the oracle.
        oracle = newOracle;
    }
}
