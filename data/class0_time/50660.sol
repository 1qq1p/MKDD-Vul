pragma solidity ^0.4.19;

contract PLBToken is UnboundedRegularToken {

    uint public totalSupply = 10*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "Palau Bei Token";
    string constant public symbol = "PLB";

    function PLBToken() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
}