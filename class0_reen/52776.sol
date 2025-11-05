pragma solidity ^0.4.24;








contract FusToken is PausableToken {
  string public constant name = "FusChain"; 
  string public constant symbol = "FUS"; 
  uint8 public constant decimals = 18; 

  uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));

  


  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}