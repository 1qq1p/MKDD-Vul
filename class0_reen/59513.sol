pragma solidity ^0.4.15;

library SafeMath {
  function mul(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x * y;
    assert((x == 0) || (z / x == y));
    return z;
  }
  
  function div(uint256 x, uint256 y) internal constant returns (uint256) {
    
    uint256 z = x / y;
    
    return z;
  }
  
  function sub(uint256 x, uint256 y) internal constant returns (uint256) {
    assert(y <= x);
    return x - y;
  }
  
  function add(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x + y;
    assert((z >= x) && (z >= y));
    return z;
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  





  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    
    

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  




  function approve(address _spender, uint256 _value) returns (bool) {

    
    
    
    
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  





  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}
