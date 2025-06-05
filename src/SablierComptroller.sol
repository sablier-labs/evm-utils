// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { Errors } from "./libraries/Errors.sol";
import { ISablierComptroller } from "./interfaces/ISablierComptroller.sol";
import { RoleAdminable } from "./RoleAdminable.sol";

/// @title SablierComptroller
/// @notice See the documentation in {ISablierComptroller}.
contract SablierComptroller is ISablierComptroller, RoleAdminable {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierComptroller
    uint256 public constant override MAX_FEE_USD = 100e8;

    /// @dev A struct to hold the fees for airdrops.
    AirdropsFees private airdropsFees;

    /// @dev A struct to hold the fees for flow streams.
    FlowFees private flowFees;

    /// @dev A struct to hold the fees for lockup streams.
    LockupFees private lockupFees;

    /// @inheritdoc ISablierComptroller
    address public override oracle;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if `newFeeUSD` exceeds the maximum allowed fee.
    modifier notExceedMaxFeeUSD(uint256 newFeeUSD) {
        _notExceedMaxFeeUSD(newFeeUSD);
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialAdmin The address of the initial contract admin.
    /// @param initialAirdropMinFeeUSD The initial airdrops min USD fee charged.
    /// @param initialFlowMinFeeUSD The initial flow min USD fee charged.
    /// @param initialLockupMinFeeUSD The initial lockup min USD fee charged.
    /// @param initialOracle The initial oracle contract address.
    constructor(
        address initialAdmin,
        uint256 initialAirdropMinFeeUSD,
        uint256 initialFlowMinFeeUSD,
        uint256 initialLockupMinFeeUSD,
        address initialOracle
    )
        RoleAdminable(initialAdmin)
    {
        airdropsFees.minFeeUSD = initialAirdropMinFeeUSD;
        flowFees.minFeeUSD = initialFlowMinFeeUSD;
        lockupFees.minFeeUSD = initialLockupMinFeeUSD;

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

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWei(uint256 minFeeUSD) external view override returns (uint256) {
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiAirdrops() external view override returns (uint256) {
        return _calculateMinFeeWei(airdropsFees.minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiFlow() external view override returns (uint256) {
        return _calculateMinFeeWei(flowFees.minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiLockup() external view override returns (uint256) {
        return _calculateMinFeeWei(lockupFees.minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiAirdropsFor(address campaignCreator) external view override returns (uint256) {
        uint256 minFeeUSD = _getAirdropsCustomFeeUSD(campaignCreator);
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiFlowFor(address sender) external view override returns (uint256) {
        uint256 minFeeUSD = _getFlowCustomFeeUSD(sender);
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function calculateMinFeeWeiLockupFor(address sender) external view override returns (uint256) {
        uint256 minFeeUSD = _getLockupCustomFeeUSD(sender);
        return _calculateMinFeeWei(minFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function getAirdropsCustomFeeUSD(address campaignCreator) external view override returns (uint256) {
        return _getAirdropsCustomFeeUSD(campaignCreator);
    }

    /// @inheritdoc ISablierComptroller
    function getAirdropsMinFeeUSD() external view override returns (uint256) {
        return airdropsFees.minFeeUSD;
    }

    /// @inheritdoc ISablierComptroller
    function getFlowCustomFeeUSD(address sender) external view override returns (uint256) {
        return _getFlowCustomFeeUSD(sender);
    }

    /// @inheritdoc ISablierComptroller
    function getFlowMinFeeUSD() external view override returns (uint256) {
        return flowFees.minFeeUSD;
    }

    /// @inheritdoc ISablierComptroller
    function getLockupCustomFeeUSD(address sender) external view override returns (uint256) {
        return _getLockupCustomFeeUSD(sender);
    }

    /// @inheritdoc ISablierComptroller
    function getLockupMinFeeUSD() external view override returns (uint256) {
        return lockupFees.minFeeUSD;
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierComptroller
    function collectFees(address feeRecipient) external override {
        // Check: if `msg.sender` has neither the {RoleAdminable.FEE_COLLECTOR_ROLE} role nor is the contract admin,
        // `feeRecipient` must be the admin address.
        bool hasRoleOrIsAdmin = _hasRoleOrIsAdmin({ role: FEE_COLLECTOR_ROLE, account: msg.sender });
        if (!hasRoleOrIsAdmin && feeRecipient != admin) {
            revert Errors.SablierComptroller_FeeRecipientNotAdmin({ feeRecipient: feeRecipient, admin: admin });
        }

        uint256 feeAmount = address(this).balance;

        // Effect: transfer the fees to the fee recipient.
        (bool success,) = feeRecipient.call{ value: feeAmount }("");

        // Revert if the call failed.
        if (!success) {
            revert Errors.SablierComptroller_FeeTransferFailed(feeRecipient, feeAmount);
        }

        // Log the fee withdrawal.
        emit CollectFees(admin, feeRecipient, feeAmount);
    }

    /// @inheritdoc ISablierComptroller
    function disableAirdropsCustomFeeUSD(address campaignCreator) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        delete airdropsFees.customFeesUSD[campaignCreator];

        // Log the reset.
        emit DisableAirdropsCustomFeeUSD(campaignCreator);
    }

    /// @inheritdoc ISablierComptroller
    function disableFlowCustomFeeUSD(address sender) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        delete flowFees.customFeesUSD[sender];

        // Log the reset.
        emit DisableFlowCustomFeeUSD(sender);
    }

    /// @inheritdoc ISablierComptroller
    function disableLockupCustomFeeUSD(address sender) external override onlyRole(FEE_MANAGEMENT_ROLE) {
        delete lockupFees.customFeesUSD[sender];

        // Log the reset.
        emit DisableLockupCustomFeeUSD(sender);
    }

    /// @inheritdoc ISablierComptroller
    function execute(address target, bytes calldata data) external override onlyAdmin returns (bytes memory response) {
        bool success;

        // Interactions: call the target contract with the provided data.
        (success, response) = target.call(data);

        // Log the execution.
        emit Execute(target, data, response);

        // Check if the call was successful or not.
        if (!success) {
            // If there is return data, the call reverted with a reason or a custom error, which we bubble up.
            if (response.length > 0) {
                assembly {
                    // The length of the data is at `response`, while the actual data is at `response + 32`.
                    let returndata_size := mload(response)
                    revert(add(response, 32), returndata_size)
                }
            } else {
                revert Errors.SablierComptroller_ExecutionFailed();
            }
        }
    }

    /// @inheritdoc ISablierComptroller
    function setAirdropsCustomFeeUSD(
        address campaignCreator,
        uint256 customFeeUSD
    )
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(customFeeUSD)
    {
        // Effect: enable the custom fee for the user if it is not already enabled.
        if (!airdropsFees.customFeesUSD[campaignCreator].enabled) {
            airdropsFees.customFeesUSD[campaignCreator].enabled = true;
        }

        // Effect: update the custom fee for the provided campaign creator.
        airdropsFees.customFeesUSD[campaignCreator].fee = customFeeUSD;

        // Log the update.
        emit SetAirdropsCustomFeeUSD(campaignCreator, customFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setAirdropsMinFeeUSD(uint256 newMinFeeUSD)
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(newMinFeeUSD)
    {
        // Load what the previous fee will be.
        uint256 previousMinFeeUSD = airdropsFees.minFeeUSD;

        // Effect: update the airdrops min USD fee.
        airdropsFees.minFeeUSD = newMinFeeUSD;

        // Log the update.
        emit SetAirdropsMinFeeUSD(newMinFeeUSD, previousMinFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setFlowCustomFeeUSD(
        address sender,
        uint256 customFeeUSD
    )
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(customFeeUSD)
    {
        // Effect: enable the custom fee for the user if it is not already enabled.
        if (!flowFees.customFeesUSD[sender].enabled) {
            flowFees.customFeesUSD[sender].enabled = true;
        }

        // Effect: update the custom fee for the provided sender.
        flowFees.customFeesUSD[sender].fee = customFeeUSD;

        // Log the update.
        emit SetFlowCustomFeeUSD(sender, customFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setFlowMinFeeUSD(uint256 newMinFeeUSD)
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(newMinFeeUSD)
    {
        // Load what the previous fee will be.
        uint256 previousMinFeeUSD = flowFees.minFeeUSD;

        // Effect: update the flow min USD fee.
        flowFees.minFeeUSD = newMinFeeUSD;

        // Log the update.
        emit SetFlowMinFeeUSD(newMinFeeUSD, previousMinFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setLockupCustomFeeUSD(
        address sender,
        uint256 customFeeUSD
    )
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(customFeeUSD)
    {
        // Effect: enable the custom fee for the user if it is not already enabled.
        if (!lockupFees.customFeesUSD[sender].enabled) {
            lockupFees.customFeesUSD[sender].enabled = true;
        }

        // Effect: update the custom fee for the provided sender.
        lockupFees.customFeesUSD[sender].fee = customFeeUSD;

        // Log the update.
        emit SetLockupCustomFeeUSD(sender, customFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setLockupMinFeeUSD(uint256 newMinFeeUSD)
        external
        override
        onlyRole(FEE_MANAGEMENT_ROLE)
        notExceedMaxFeeUSD(newMinFeeUSD)
    {
        // Load what the previous fee will be.
        uint256 previousMinFeeUSD = lockupFees.minFeeUSD;

        // Effect: update the lockup min USD fee.
        lockupFees.minFeeUSD = newMinFeeUSD;

        // Log the update.
        emit SetLockupMinFeeUSD(newMinFeeUSD, previousMinFeeUSD);
    }

    /// @inheritdoc ISablierComptroller
    function setOracle(address newOracle) external override onlyAdmin {
        address currentOracle = oracle;

        // Effects: set the new oracle.
        _setOracle(newOracle);

        // Log the update.
        emit SetOracle({ admin: msg.sender, newOracle: newOracle, previousOracle: currentOracle });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE READ-ONLY FUNCTIONS
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
    function _getAirdropsCustomFeeUSD(address campaignCreator) private view returns (uint256) {
        ISablierComptroller.CustomFeeUSD memory customFee = airdropsFees.customFeesUSD[campaignCreator];
        return customFee.enabled ? customFee.fee : airdropsFees.minFeeUSD;
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _getFlowCustomFeeUSD(address sender) private view returns (uint256) {
        ISablierComptroller.CustomFeeUSD memory customFee = flowFees.customFeesUSD[sender];
        return customFee.enabled ? customFee.fee : flowFees.minFeeUSD;
    }

    /// @dev See the documentation for the user-facing functions that call this internal function.
    function _getLockupCustomFeeUSD(address sender) private view returns (uint256) {
        ISablierComptroller.CustomFeeUSD memory customFee = lockupFees.customFeesUSD[sender];
        return customFee.enabled ? customFee.fee : lockupFees.minFeeUSD;
    }

    /// @dev A private function is used instead of inlining this logic in a modifier because Solidity copies modifiers
    /// into every function that uses them.
    function _notExceedMaxFeeUSD(uint256 newFeeUSD) private pure {
        // Check: the new fee is not greater than the maximum allowed.
        if (newFeeUSD > MAX_FEE_USD) {
            revert Errors.SablierComptroller_MaxFeeUSDExceeded(newFeeUSD, MAX_FEE_USD);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                          PRIVATE STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

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
