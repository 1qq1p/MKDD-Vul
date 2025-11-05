pragma solidity ^0.4.15;

contract CertiPreSaleToken is StandardToken {
    string public name = "CERTI-A SingleSource";
    string public symbol = "CERTI-A";
    uint public decimals = 18;
    uint public totalSupply = 131578948 ether;

    function CertiPreSaleToken() public {
        balances[msg.sender] = totalSupply;
    }
}