











pragma solidity 0.4.19;

contract LuckChain is RegularToken {

    uint public totalSupply = 21*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "LuckChain";
    string constant public symbol = "LUCK";

    function LuckChain() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}