// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";


contract StakingAppTest is Test{

    StakingToken stakingToken;
    StakingApp stakingApp;
    // StakingToken Parameters
    string name_ = "Staking Token";
    string symbol_ = "STK";
    // StakingApp Parameters
    address public owner_ = vm.addr(1);
    uint256 public stakingPeriod_ = 100000000000;
    uint256 public fixedStakingAmount_ = 10;
    uint256 public rewardPerPeriod_ = 1 ether;
    address public randomUser = vm.addr(2);

    function setUp() public{
        stakingToken = new StakingToken(name_,symbol_);
        stakingApp = new StakingApp(address(stakingToken),owner_,stakingPeriod_,fixedStakingAmount_,rewardPerPeriod_);
    }
    function testStakingTokenCorrectlyDeployed() external view{
        assert(address(stakingToken)!=address(0));
    }
    function testStakingAppCorrectlyDeployed() external view{
        assert(address(stakingApp)!=address(0));
    }
    
    function testChangeStakingPeriodReverts() external{
        vm.startPrank(randomUser);

        uint256 newStakingPeriod_ = 1000000;
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod_);

        vm.stopPrank();
    }
     function testShouldChangeStakingPeriod() external{
        vm.startPrank(owner_);

        uint256 newStakingPeriod_ = 1000000;
        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();
        stakingApp.changeStakingPeriod(newStakingPeriod_);
        uint256 stakingPeriodAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodBefore!=stakingPeriodAfter);
        assert(newStakingPeriod_==stakingPeriodAfter);

        vm.stopPrank();
    }

    // Test Feed Contract
    function testFeedContractNotOwnerReverts() external {
        vm.startPrank(randomUser);

        vm.expectRevert();
        stakingApp.feedContract();

        vm.stopPrank;
    }
    function testFeedContractShouldWork() external {
        vm.startPrank(owner_);

        vm.deal(owner_, 10 ether);
        uint256 balanceBeforeFeed = address(stakingApp).balance;
        uint256 amountToFeed = 1 ether;
        stakingApp.feedContract{value:amountToFeed}();
        uint256 balanceAfterFeed = address(stakingApp).balance;
        assert(balanceAfterFeed-amountToFeed==balanceBeforeFeed);

        vm.stopPrank();
    }

    // Test Deposit Token
    function testDepositIncorrectAmountRevert() external{
        vm.startPrank(randomUser);

        uint256 amountDepositToken_ = 15 ether;
        vm.expectRevert("Invalid amount");
        stakingApp.depositToken(amountDepositToken_);

        vm.stopPrank();
    }
     function testDepositCorrectAmount() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);     
        
        vm.stopPrank();
    }
    function testShouldDepositOnlyOnce() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp); 

        stakingToken.mint(fixedStakingAmount_);
        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        vm.expectRevert("Already Deposited your tokens");
        stakingApp.depositToken(fixedStakingAmount_);    
        
        vm.stopPrank();
    }

    // Test Withdraw Token
    function testWithdrawTokenBalanceZero() external{
        vm.startPrank(randomUser);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        stakingApp.withDrawToken();
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        assert(userBalanceBefore==userBalanceAfter);

        vm.stopPrank();
    }
    function testWithdrawToken() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);  

        uint256 userBalanceBefore2 = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInStaking = stakingApp.userBalance(randomUser);
        stakingApp.withDrawToken();
        uint256 userBalanceAfter2 = IERC20(stakingToken).balanceOf(randomUser);
        assert(userBalanceAfter2 == userBalanceBefore2 + userBalanceInStaking);

        vm.stopPrank();
    }

    // Test Function Claim Rewards
    function testClaimRewardsNoTokensRevert() external{
        vm.startPrank(randomUser);

        vm.expectRevert("You dont have any token deposited");
        stakingApp.claimRewards();

        vm.stopPrank();
    }
    function testCanNotClaimBeforeStakingPeriod() external {
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);

        vm.expectRevert("You cannot reclaim yet");
        stakingApp.claimRewards();

        vm.stopPrank();
    }
    function testClaimRewardsNoEther() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);

        vm.warp(block.timestamp+stakingPeriod_); // To manipulate the time.
        vm.expectRevert("Transfer failed");
        stakingApp.claimRewards();

        vm.stopPrank();
    }
     function testClaimRewards() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);

        vm.stopPrank();
        vm.startPrank(owner_);

        vm.deal(owner_, 10 ether);
        uint256 balanceBeforeFeed = address(stakingApp).balance;
        uint256 amountToFeed = 10 ether;
        stakingApp.feedContract{value:amountToFeed}();
        uint256 balanceAfterFeed = address(stakingApp).balance;
        assert(balanceAfterFeed-amountToFeed==balanceBeforeFeed);

        vm.stopPrank();
        vm.startPrank(randomUser);

        vm.warp(block.timestamp+stakingPeriod_); // To manipulate the time.
        uint256 etherAmountBeforeClaim = randomUser.balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfterClaim = randomUser.balance;
        uint256 elapsedPeriod = stakingApp.elapsedPeriod(randomUser);
        assert(etherAmountAfterClaim-etherAmountBeforeClaim==rewardPerPeriod_);
        assert(elapsedPeriod==block.timestamp);
    
        vm.stopPrank();
    }
    function testClaimRewardsTwiceInARow() external{
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        IERC20(stakingToken).approve(address(stakingApp),fixedStakingAmount_);
        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        stakingApp.depositToken(fixedStakingAmount_);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter-userBalanceBefore==fixedStakingAmount_);
        assert(elapsedPeriodBefore==0);
        assert(elapsedPeriodAfter==block.timestamp);

        vm.stopPrank();
        vm.startPrank(owner_);

        vm.deal(owner_, 10 ether);
        uint256 balanceBeforeFeed = address(stakingApp).balance;
        uint256 amountToFeed = 10 ether;
        stakingApp.feedContract{value:amountToFeed}();
        uint256 balanceAfterFeed = address(stakingApp).balance;
        assert(balanceAfterFeed-amountToFeed==balanceBeforeFeed);

        vm.stopPrank();
        vm.startPrank(randomUser);

        vm.warp(block.timestamp+stakingPeriod_); // To manipulate the time.
        uint256 etherAmountBeforeClaim = randomUser.balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfterClaim = randomUser.balance;
        uint256 elapsedPeriod = stakingApp.elapsedPeriod(randomUser);
        assert(etherAmountAfterClaim-etherAmountBeforeClaim==rewardPerPeriod_);
        assert(elapsedPeriod==block.timestamp);

        vm.expectRevert("You cannot reclaim yet");
        stakingApp.claimRewards();

        vm.stopPrank();
    }
}