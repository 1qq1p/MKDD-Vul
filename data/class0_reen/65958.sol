pragma solidity ^0.4.13;

contract Ether2x is StandardToken, owned, allowMonthly {

  string public constant name = "Ethereum 2x";
  string public constant symbol = "E2X";
  uint8 public constant decimals = 8;

  bool public initialDrop;
  uint256 public inititalSupply = 10000000 * (10 ** uint256(decimals));
  uint256 public totalSupply;

  address NULL_ADDRESS = address(0);

  uint public nonce = 0;

  event NonceTick(uint _nonce);
  
  function incNonce() public {
    nonce += 1;
    if(nonce > 100) {
        nonce = 0;
    }
    NonceTick(nonce);
  }

  
  event NoteChanged(string newNote);
  string public note = "Earn from your Ether with Ease.";
  function setNote(string note_) public onlyOwner {
    note = note_;
    NoteChanged(note);
  }

  
  event PerformingMonthlyMinting(uint amount);
  
  function monthlyMinting() public onlyOwner {
    uint256 totalAmt;
    if (initialDrop) {
        totalAmt = totalSupply / 4;
        initialDrop = false;
    } else {
        
        totalAmt = (totalSupply / 100) + (totalSupply / 500);
    }
    PerformingMonthlyMinting(totalAmt);
    assert(totalAmt > 0);

    balances[owner] += totalAmt;
    totalSupply += totalAmt;
    Transfer(0, owner, totalAmt);
    
    useMonthlyAccess(); 
  }  
  
  
  
  event rewardSent(uint amount);
  function distributeReward(address recipient, uint baseAmt) public onlyOwner {
    
    uint256 holdingBonus = balances[recipient] / 500;
    uint256 reward = baseAmt + holdingBonus;
    
    rewardSent(reward);
    
    assert(reward > 0);
    assert(balances[owner] >= reward);
    
    require(recipient != NULL_ADDRESS);

    balances[owner] -= reward;
    balances[recipient] += reward;
    Transfer(owner, recipient, reward);
    
  }

  


  function Ether2x() public {
    totalSupply = inititalSupply;
    balances[msg.sender] = totalSupply;
    initialDrop = true;
  }
}