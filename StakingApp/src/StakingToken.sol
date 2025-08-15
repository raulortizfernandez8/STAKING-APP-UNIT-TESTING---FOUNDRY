// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20{

    //Variables




    constructor(string memory name_, string memory symbol_) ERC20(name_,symbol_){}

    function mint(uint256 value_) external{
        _mint(msg.sender, value_);
    }







}

