pragma solidity ^0.4.20;

contract PXGToken is StandardToken, BurnableToken {
  string public constant name = "PlayGame"; 
  string public constant symbol = "PXG"; 
  uint8 public constant decimals = 18; 
  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
  function PXGToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}