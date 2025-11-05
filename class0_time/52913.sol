pragma solidity ^0.4.24;

library Math {
  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a >= _b ? _a : _b;
  }

  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {
    return _a < _b ? _a : _b;
  }

  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a >= _b ? _a : _b;
  }

  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a < _b ? _a : _b;
  }
}

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

contract PlusToken is StandardToken {
  string public constant name = "PayPlus Token";
  string public constant symbol = "PLUS";
  uint8 public constant decimals = 18;                      
  uint256 public INITIAL_SUPPLY = uint256(uint256(500000000) * uint256(1000000000000000000));

  constructor() public
  {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}