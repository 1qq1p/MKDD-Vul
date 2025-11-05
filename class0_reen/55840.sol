pragma solidity ^0.4.11;





 library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

















contract ERC20Interface
{
  

  

  
  
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value);

  
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value);

  

  

  
  function totalSupply() public constant returns (uint256);

  
  
  function balanceOf(address _addr) public constant returns (uint256);

  
  
  
  function allowance(address _owner, address _spender) public constant
  returns (uint256);

  
  
  
  function transfer(address _to, uint256 _amount) public returns (bool);

  
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _amount)
  public returns (bool);

  
  
  
  
  function approve(address _spender, uint256 _amount) public returns (bool);
}
