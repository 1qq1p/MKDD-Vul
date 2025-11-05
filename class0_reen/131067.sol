pragma solidity 0.4.24;

contract BiXuToken is UnboundedRegularToken {

    uint public totalSupply = 10*10**26;
    uint8 constant public decimals = 18;
    string constant public name = "BiXuToken";
    string constant public symbol = "BXT";

    function BiXuToken() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}