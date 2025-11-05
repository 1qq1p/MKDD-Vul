pragma solidity ^0.4.16;






contract MRDSCoinToken is BurnableToken {
    
  string public constant name = "MRDS Coin Token";
  string public constant symbol = "MRDS";
 
  uint32 public constant decimals = 18;
  uint256 public INITIAL_SUPPLY = 270000000 * 1 ether; 

  function MRDSCoinToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
    
}
