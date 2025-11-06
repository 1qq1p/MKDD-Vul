pragma solidity ^0.4.18;
 



contract Rydbergtoken is StandardToken, Ownable {
  string public constant name = "Rydberg";
  string public constant symbol = "RYD";
  uint public constant decimals = 11;
  uint256 public initialSupply;
    
  function Rydbergtoken () { 
     totalSupply = 100000000 * 10 ** decimals;
      balances[0x74aa529e3C2DC8b49c53bA2baDB49B50c64964eE] = totalSupply;
      initialSupply = totalSupply; 
        Transfer(0, this, totalSupply);
        Transfer(this, 0x74aa529e3C2DC8b49c53bA2baDB49B50c64964eE, totalSupply);
  }
 function distribute55M(address[] addresses) onlyOwner {
    
    for (uint i = 0; i < addresses.length; i++) {
      balances[owner] -= 698678861788617;
      balances[addresses[i]] += 698678861788617;
      Transfer(owner, addresses[i], 698678861788617);
    }
  }
}