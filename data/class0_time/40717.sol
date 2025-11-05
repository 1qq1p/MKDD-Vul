pragma solidity ^0.4.16;















contract FolkCoin is BurnableToken {
    
  string public constant name = "Folk Coin";
   
  string public constant symbol = "FOLK";
    
  uint8 public constant decimals = 18;

  uint256 public INITIAL_SUPPLY = 15000000 * 1 ether;

  function FolkCoin  () {
    totalSupply = INITIAL_SUPPLY;
    balances[0x1559a17671ce3E858bA98066CAF39F23064bc331] = INITIAL_SUPPLY;
  }
    
}
