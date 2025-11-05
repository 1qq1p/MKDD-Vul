pragma solidity ^0.4.18;
 


contract DT is TheLiquidToken {
  string public constant name = "Deuterium Coin";
      string public constant symbol = "DTM";
  uint public constant decimals = 8;
  uint256 public initialSupply = 4000000000000000000;
    
  
  function DT () { 
     totalSupply = 4000000000000000000;
      balances[msg.sender] = totalSupply;
      initialSupply = totalSupply; 
        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, totalSupply);
  }
}