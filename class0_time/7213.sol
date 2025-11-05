pragma solidity ^0.4.18;

contract BasicFreezableToken is ERC20Implementation {

  address[] internal investors;
  mapping (address => bool) internal isInvestor;
  bool frozen;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(!frozen);
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

}
