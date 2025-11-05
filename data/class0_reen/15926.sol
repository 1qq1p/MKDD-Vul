pragma solidity ^0.4.11;

contract MintableToken is StandardToken, Ownable {

  bool public mintingFinished = false;

  
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state  );


  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply = safeAdd(totalSupply,amount);
    balances[receiver] = safeAdd(balances[receiver],amount);


    Transfer(0, receiver, amount);
  }


  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }

  modifier onlyMintAgent() {
    
    if(!mintAgents[msg.sender]) {
        throw;
    }
    _;
  }

  
  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }
}
