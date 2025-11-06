pragma solidity ^0.4.16;
 





contract MyCoinToken is BurnableToken {
    
  string public constant name = "My Coin Token";
   
  string public constant symbol = "MCT";
    
  uint32 public constant decimals = 18;
 
  uint256 public INITIAL_SUPPLY = 10000000 * 1 ether;
 
  function MyCoinToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
    
} 
