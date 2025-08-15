// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Staking fixed amount 10. Only can deposit 10 and it has to be in once.
// Staking Period.

contract StakingApp is Ownable{
    // Variables
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAMount;
    uint256 public rewardPerPeriod;
    mapping(address=>uint256) public userBalance;
    mapping(address=>uint256) public elapsedPeriod;

    // Events
    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositToken(address userAddress_, uint256 amountDeposited_);
    event WithDrawToken(address userAddress_, uint256 amountWithDraw_);
    event EtherFeed(uint256 amount_);

    // We must initialize the Ownable constructor as well so we pass him the address will be the owner.
    // We can use now the function OnlyOwner() and owner which returns the owner.
    constructor(address stakingToken_,address owner_, uint256 stakingPeriod_, uint256 fixedStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_){
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAMount = fixedStakingAmount_;
        rewardPerPeriod = rewardPerPeriod_;
    }

    // Functions

    // Functions external
    // 1.Deposit
    function depositToken(uint256 amountDepositToken_) external{
        require(amountDepositToken_==fixedStakingAMount,"Invalid amount");
        require(userBalance[msg.sender]==0,"Already Deposited your tokens");
        IERC20(stakingToken).transferFrom(msg.sender,address(this),amountDepositToken_);
        userBalance[msg.sender]+=amountDepositToken_;
        elapsedPeriod[msg.sender] = block.timestamp;
        emit DepositToken(msg.sender,amountDepositToken_);
    }
    // 2.Withdraw
    function withDrawToken() external{ // CEI Pattern
        uint256 userBalance_ = userBalance[msg.sender]; // We caché the value so we can follow the CEI pattern & not transfer 0.
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender,userBalance_);
        emit WithDrawToken(msg.sender, userBalance_);
    }
    // 3.Claim rewards
    function claimRewards() external{
        // 1.Check Balance
        require(userBalance[msg.sender]==fixedStakingAMount,"You dont have any token deposited");
        // 2.Check Period
        uint256 elapsedPeriod_ = block.timestamp - elapsedPeriod[msg.sender];
        require(elapsedPeriod_ >= stakingPeriod,"You cannot reclaim yet");
        // 3.Update State
        elapsedPeriod[msg.sender] = block.timestamp;
        // 4.WithDrawRewards
        (bool success,) = msg.sender.call{value: rewardPerPeriod}(""); // The reward is in ether not in the Token Staked
        require(success,"Transfer failed");
    }

     function feedContract() external payable onlyOwner{ // The rewards will be in Ether so the contract must be feed so users can receive their rewards.
        emit EtherFeed(msg.value);
     }
     function changeStakingPeriod(uint256 newStakingPeriod_) external onlyOwner{
        stakingPeriod = newStakingPeriod_;
        emit ChangeStakingPeriod(newStakingPeriod_);
    }

    

















}