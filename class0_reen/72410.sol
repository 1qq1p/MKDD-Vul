pragma solidity ^0.4.23;


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


contract FHToken is StandardToken {
  
  string public name = "Finder Hyper";
  string public symbol = "FH";
  uint8 public decimals = 18;

  

  

  
  constructor() public {
    
    _totalSupply = 1900000000 * (10 ** uint256(decimals));

    _balances[msg.sender] = _totalSupply;
    emit Transfer(0x0, msg.sender, _totalSupply);
  }


  
}