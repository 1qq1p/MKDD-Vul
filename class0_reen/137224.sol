pragma solidity 0.4.25;

contract  YaoChainToken is UnboundedRegularToken {

    uint public totalSupply = 1000000000000000000000000000;
    uint8 constant public decimals = 18;
    string constant public name = "YaoChainToken";
    string constant public symbol = "YCT";

    function YaoChainToken() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}