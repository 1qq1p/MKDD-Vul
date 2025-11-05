pragma solidity ^0.4.23;


contract PCT is Base {
    uint256 public reserveSupply = 1000000 * kUnit;

    constructor() public {
        totalSupply = reserveSupply;
        balanceOf[msg.sender] = totalSupply;
        name = "PCT Token";
        symbol = "PCT";
    }
}