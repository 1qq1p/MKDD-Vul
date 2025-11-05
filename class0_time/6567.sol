pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EtherDoge is MintableToken {
  string public constant name = "EtherDoge";
  string public constant symbol = "EDOGE";
  uint   public constant decimals = 18;
  uint   public unlockTimeStamp = 0;  

  mapping (address => bool) private _lockByPass;
  
  function EtherDoge(uint unlockTs){
    setUnlockTimeStamp(unlockTs);
  }

  function setUnlockTimeStamp(uint _unlockTimeStamp) onlyOwner {
    unlockTimeStamp = _unlockTimeStamp;
  }

  function airdrop(address[] addresses, uint amount) onlyOwner{
    require(amount > 0);
    for (uint i = 0; i < addresses.length; i++) {
       super.transfer(addresses[i], amount);
    }
  }

  function transfer(address _to, uint _value) returns (bool success) {
    if (now < unlockTimeStamp && !_lockByPass[msg.sender]) return false;
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    if (now < unlockTimeStamp && !_lockByPass[_from]) return false;
    return super.transferFrom(_from, _to, _value);
  }

  function setLockByPass(address[] addresses, bool locked) onlyOwner{
    for (uint i = 0; i < addresses.length; i++) {
       _lockByPass[addresses[i]] = locked;
    }
  }
}