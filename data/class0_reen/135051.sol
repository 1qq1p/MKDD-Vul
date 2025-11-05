pragma solidity ^0.4.23;

contract TKSS is Base {
    uint256 public release = 10000000000 * tokenUnit;
    constructor() public {
        totalSupply = release;
        balanceOf[msg.sender] = totalSupply;
        name = "TKSS Coin";
        symbol = "TKSS";
    }
}