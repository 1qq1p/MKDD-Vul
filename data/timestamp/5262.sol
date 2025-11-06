pragma solidity ^0.4.24;







contract PMD is StandardToken {

    string public constant name = "PMD Token";
    string public constant symbol = "PMD";
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 1000000000 * (10**decimals);
    uint256 public totalSupplied = 0;

    constructor() public {
        balances[msg.sender] = totalSupply;
        totalSupplied = totalSupply;
    }

}