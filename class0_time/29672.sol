pragma solidity ^0.4.21;

contract TEC is StandardToken {
    string public name = "仟电链";
    string public symbol = "TEC";
    uint public decimals = 18;
    uint public totalSupply = 1000 * 1000 * 1000 ether;

    function TEC() public {
        balances[msg.sender] = totalSupply;
    }
}