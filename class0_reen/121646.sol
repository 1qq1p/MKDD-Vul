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








contract Humanity is StandardToken {
    using SafeMath for uint;
    
    string public symbol;
    string public name;
    uint8 public decimals;

    constructor() public {
        symbol = "HUM";
        name = "Humanity";
        decimals = 18;
        totalSupply_ = 7700000000 * 10**uint(decimals);
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
}