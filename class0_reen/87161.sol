pragma solidity ^0.4.24;

contract AKJToken is BurnableToken, StandardToken, AccessControl
{
  string public constant name = "AKJ"; 
  string public constant symbol = "AKJ"; 
  uint8 public constant decimals = 18; 

  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals)); 

  


  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
  function transfer(address _to, uint256 _value) public onlyWhitelisted(_to) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public onlyWhitelistedParties(_from, _to) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public onlyWhitelisted(_spender) returns (bool) {
    return super.approve(_spender, _value);
  }




}