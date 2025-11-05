pragma solidity 0.4.19;

contract NEBlockchain is UnboundedRegularToken {

    uint public totalSupply = 10*10**17;
    uint8 constant public decimals = 8;
    string constant public name = "New Energy BlockChain Token";
    string constant public symbol = "NEB";

    function NEBlockchain() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}