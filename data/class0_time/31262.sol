pragma solidity ^0.4.22;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}








contract ERC223StandardToken is StandardToken, ERC223 {

    string public name = "";
    string public symbol = "";
    uint8 public decimals = 18;

    function ERC223StandardToken(string _name, string _symbol, uint8 _decimals, address _owner, uint256 _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        totalSupply_ = _totalSupply;
        balances[_owner] = _totalSupply;
        Transfer(0x0, _owner, _totalSupply);
    }
}


