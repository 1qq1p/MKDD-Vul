pragma solidity ^0.4.11;





contract TradeTrustToken is StandardToken {
  string public name = "TradeTrust";
  string public symbol = "TRT";
  uint256 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 6500000 * (10 ** uint256(18));

  event Burn(address indexed owner, uint256 value);

  


  constructor() public{
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function burn(uint256 _value) public returns (bool) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(msg.sender, _value);
    return true;
  }
}