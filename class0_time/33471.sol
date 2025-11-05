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






contract ERC20 {

  uint256 public totalSupply;
  
  function balanceOf(address _owner) constant returns (uint256);
  function transfer(address _to, uint256 _value) returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool);
  function approve(address _spender, uint256 _value) returns (bool);
  function allowance(address _owner, address _spender) constant returns (uint256);
  
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}








