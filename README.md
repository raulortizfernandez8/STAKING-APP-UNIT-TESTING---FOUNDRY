# 🪙 StakingApp Project

## 📌 Overview
This project consists of **two smart contracts**:

1. **A simple ERC-20 Token**  
   - Created using the OpenZeppelin ERC-20 implementation.
   - Provides standard token functions such as `transferFrom`, `balanceOf`, and `approve`.

2. **A Staking Application (`StakingApp`)**  
   - Allows users to stake **a fixed maximum amount** of the ERC-20 token configured by the contract owner.
   - Includes a staking period after which users can claim rewards in **Ether**.
   - Staking period and reward amount are configurable by the owner.
   - Users can withdraw their staked tokens anytime.
   - Rewards are **fixed in Ether** and distributed after the staking period.

---

## ⚙️ Features

### 🔹 Fixed Maximum Deposit
- Users can only deposit **exactly** the fixed amount (`fixedStakingAmount`) set by the owner.
- Each address can only deposit **once**.

### 🔹 Configurable Staking Period
- The `stakingPeriod` defines how long a user must wait before claiming rewards.
- The owner can update this period with `changeStakingPeriod`.

### 🔹 Rewards in Ether
- Rewards are paid **in Ether**, not in the staked token.
- The owner must **fund** the contract with Ether using `feedContract`.
- The reward per period is a fixed value set by the owner at deployment.

### 🔹 Withdraw Anytime
- Users can withdraw their staked tokens at any time with `withDrawToken`.

### 🔹 Claim Rewards
- After the staking period has elapsed since the last claim, users can call `claimRewards` to receive their Ether reward.
- Claiming resets the user's staking timer.

🛠️ Technical Details
OpenZeppelin:

Ownable for access control

IERC20 for interacting with the token

Security patterns:

Checks-Effects-Interactions (CEI) applied in withdrawals.

🧪 Testing
Comprehensive unit tests implemented.

All functionalities verified:

Deposits

Withdrawals

Reward claims

Owner functions

Failure scenarios (require conditions)

100% coverage achieved.

🔒 Security Considerations
Ensure the contract is funded with enough Ether for rewards.

Only the owner can change staking parameters.

Token contract must be ERC-20 compliant.

Reentrancy risks mitigated with CEI pattern.

