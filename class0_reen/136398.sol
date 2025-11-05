pragma solidity ^0.4.24;











library SafeMath {
  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); 
    uint256 c = _a / _b;
    

    return c;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}






contract SlashToken is StandardToken, Pausable {
  string public constant name = 'Slash Token';                       
  string public constant symbol = 'ST';                                       
  uint256 constant Thousand_Token = 1000 * ONE_TOKEN;
  uint256 constant Million_Token = 1000 * Thousand_Token;
  uint256 constant Billion_Token = 1000 * Million_Token;
  uint256 public constant TOTAL_TOKENS = 10 * Billion_Token;

  



  constructor() public {
    totalSupply = TOTAL_TOKENS;                               
    balances[msg.sender] = TOTAL_TOKENS;                      
  }

  




  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    return super.transfer(_to, _value);
  }

  





  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    return super.transferFrom(_from, _to, _value);
  }

  




  function approve(address _spender, uint256 _value) whenNotPaused public returns (bool) {
    return super.approve(_spender, _value);
  }
}