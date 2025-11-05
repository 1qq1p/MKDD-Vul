pragma solidity 0.4.19;

contract XGToken is UnboundedRegularToken {

    uint public totalSupply = 5201314;
    uint8 constant public decimals = 18;
    string constant public name = "XGToken";
    string constant public symbol = "XG";

    function XGToken() {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }
}