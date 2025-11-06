pragma solidity ^0.4.16;






contract CSFT is BurnableToken {
    
  string public constant name = "Cryptosafefundtrading";
   
  string public constant symbol = "CSFT";
    
  uint8 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;

  function CSFT  () {
    totalSupply = INITIAL_SUPPLY;
    balances[0xd9fEA37020AD04626d362BB7e2f8ad6F822EBae4] = INITIAL_SUPPLY;
  }
    
}
