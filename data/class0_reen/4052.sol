pragma solidity ^0.4.25;






contract MintableToken is StandardTokenExt {

  using SafeMathLib for uint;

  bool public mintingFinished = false;

  
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state);
  event Minted(address receiver, uint amount);

  




  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply_ = totalSupply_.plus(amount);
    balances[receiver] = balances[receiver].plus(amount);

    
    
    emit Transfer(0, receiver, amount);
  }

  


  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    emit MintingAgentChanged(addr, state);
  }

  modifier onlyMintAgent() {
    
    require(mintAgents[msg.sender]);
    _;
  }

  
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}




