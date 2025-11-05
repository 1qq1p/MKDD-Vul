pragma solidity ^0.4.11;

contract BullToken is UnlimitedAllowanceToken {

    uint8 constant public decimals = 18;
    uint public totalSupply               = 10**28; 
    string constant public name     = "Bull Token";
    string constant public symbol  = "BULL";

    function BullToken() {
        balances[msg.sender] = totalSupply;
    }
}