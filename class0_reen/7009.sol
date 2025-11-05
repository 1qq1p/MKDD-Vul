library SafeMathLib {

  function times(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function minus(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function plus(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }

}

contract MintableToken is StandardToken, Ownable {

  using SafeMathLib for uint;

  bool public mintingFinished = false;

  
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state  );

  




  function mint(address receiver, uint amount) onlyMintAgent canMint public {
    totalSupply = totalSupply.plus(amount);
    balances[receiver] = balances[receiver].plus(amount);

    
    
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

