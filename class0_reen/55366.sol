pragma solidity ^0.4.16;




contract MToken is StandardToken, Ownable {
  string public constant name = "10M Token";
  string public constant symbol = "10MT";
  uint public constant decimals = 10;
  uint256 public initialSupply;

  function MToken () { 
   totalSupply = 10000000 * 10 ** decimals;
   balances[msg.sender] = totalSupply;
   initialSupply = totalSupply; 
   Transfer(0, this, totalSupply);
   Transfer(this, msg.sender, totalSupply);
  }

  function distribute10MT(address[] addresses) onlyOwner {
    
    for (uint i = 0; i < addresses.length; i++) {
      balances[owner] -= 11669024045261 ;
      balances[addresses[i]] += 11669024045261;
      Transfer(owner, addresses[i], 11669024045261);
    }
  }
}