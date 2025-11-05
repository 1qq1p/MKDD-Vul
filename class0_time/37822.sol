pragma solidity ^0.4.17;





contract LandToken is SafeStandardToken{
  string public constant name = "LAND Token";
  string public constant symbol = "LAND";
  uint256 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 84000000 * (10 ** uint256(decimals));

  function LandToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}