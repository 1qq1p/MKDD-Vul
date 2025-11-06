pragma solidity ^0.4.24;

  









library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}






contract UpcToken is StandardToken, MintableToken {
  string public name    = "Unit Personer Token";
  string public symbol  = "UPT";
  uint8 public decimals = 18;

  
  uint256 public constant INITIAL_SUPPLY = 10000000000;

  function UpcCoin() public {
    totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
    balances[msg.sender] = totalSupply_;
  }
}