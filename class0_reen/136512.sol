pragma solidity ^0.4.17;





contract SafeBasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;

  
  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length >= size + 4);
     _;
  }
  




  function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
    require(_to != address(0));
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  




  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}




