// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {

    StakingToken stakingToken;
    string name_ = "Staking Token";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name_,symbol_);
    }
    function testStakingTokenMintsCorrectly() public{
        uint256 amount_ = 1 ether;
     
        vm.startPrank(randomUser);
        // Token balance previous
        uint256 previousBalance=IERC20(address(stakingToken)).balanceOf(randomUser); // UserA = 50 tokens
        stakingToken.mint(amount_);                                                 // Emits 1 token
        // Token balance after
        uint256 afterBalance=IERC20(address(stakingToken)).balanceOf(randomUser); // UserA = 51 tokens

        assert(afterBalance-previousBalance==amount_); // 51 tokens - 50 tokens = 1 ether.

        vm.stopPrank();

    }
}