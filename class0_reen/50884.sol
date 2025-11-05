pragma solidity ^0.4.18;

contract ParameterizedToken is CappedToken {
    string public name;

    string public symbol;

    uint256 public decimals;

    function ParameterizedToken(string _name, string _symbol, uint256 _decimals, uint256 _capIntPart) public CappedToken(_capIntPart * 10 ** _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

}
