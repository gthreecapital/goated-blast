// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

enum GasMode {
    VOID,
    CLAIMABLE
}

interface IBlast {
    // configure
    function configureContract(
        address contractAddress,
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;

    function configure(
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;

    // base configuration options
    function configureClaimableYield() external;

    function configureClaimableYieldOnBehalf(address contractAddress) external;

    function configureAutomaticYield() external;

    function configureAutomaticYieldOnBehalf(address contractAddress) external;

    function configureVoidYield() external;

    function configureVoidYieldOnBehalf(address contractAddress) external;

    function configureClaimableGas() external;

    function configureClaimableGasOnBehalf(address contractAddress) external;

    function configureVoidGas() external;

    function configureVoidGasOnBehalf(address contractAddress) external;

    function configureGovernor(address _governor) external;

    function configureGovernorOnBehalf(
        address _newGovernor,
        address contractAddress
    ) external;

    // claim yield
    function claimYield(
        address contractAddress,
        address recipientOfYield,
        uint256 amount
    ) external returns (uint256);

    function claimAllYield(
        address contractAddress,
        address recipientOfYield
    ) external returns (uint256);

    // claim gas
    function claimAllGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);

    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    ) external returns (uint256);

    function claimMaxGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);

    function claimGas(
        address contractAddress,
        address recipientOfGas,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    ) external returns (uint256);

    // read functions
    function readClaimableYield(
        address contractAddress
    ) external view returns (uint256);

    function readYieldConfiguration(
        address contractAddress
    ) external view returns (uint8);

    function readGasParams(
        address contractAddress
    )
        external
        view
        returns (
            uint256 etherSeconds,
            uint256 etherBalance,
            uint256 lastUpdated,
            GasMode
        );
}

interface IERC20Rebasing {
    // changes the yield mode of the caller and update the balance
    // to reflect the configuration
    function configure(YieldMode) external returns (uint256);

    // "claimable" yield mode accounts can call this to claim their yield
    // to another address
    function claim(
        address recipient,
        uint256 amount
    ) external returns (uint256);

    // read the claimable amount for an account
    function getClaimableAmount(
        address account
    ) external view returns (uint256);
}

contract Vault is Ownable {
    using SafeERC20 for IERC20;

    IBlast public constant BLAST =
        IBlast(0x4300000000000000000000000000000000000002);

    IERC20 public constant usdb =
        IERC20(0x4200000000000000000000000000000000000022);

    IERC20Rebasing public constant USDB =
        IERC20Rebasing(0x4200000000000000000000000000000000000022);

    event Deposit(address user, uint256 amount);

    constructor() Ownable(msg.sender) {
        USDB.configure(YieldMode.CLAIMABLE);
        BLAST.configureClaimableGas();
    }

    function getClaimableYield() external view returns (uint256) {
        return USDB.getClaimableAmount(address(this));
    }

    function claimYield(
        address recipient
    ) external onlyOwner returns (uint256 claimAmount) {
        claimAmount = USDB.getClaimableAmount(address(this));
        require(claimAmount > 0, "ClaimableYield is zero!");
        USDB.claim(recipient, claimAmount);
    }

    function deposit(address user, uint256 amount) external {
        usdb.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposit(user, amount);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        usdb.safeTransfer(to, amount);
    }
}
