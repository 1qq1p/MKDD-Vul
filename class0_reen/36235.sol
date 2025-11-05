pragma solidity ^0.4.21;




library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    assert(a == b * c + a % b); 
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}







contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  


  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length >= size + 4);
     
     
     
     _;
  }

  




  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32)  public {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

  




  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner];
  }

}





