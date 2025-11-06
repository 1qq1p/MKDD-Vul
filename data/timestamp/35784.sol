pragma solidity ^0.4.21;

contract QuickChain is StandardToken 
{
    string public name = "QuickChain";
    string public symbol = "QUC";
    uint public decimals = 18;
    uint public totalSupply = 10 * 100 * 1000 * 1000 ether;

    function QuickChain() public {
        balances[msg.sender] = totalSupply;
    }
}