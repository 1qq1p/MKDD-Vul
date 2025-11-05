pragma solidity ^0.4.24;









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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}







contract TimeLockToken is Ownable, MintableToken{
  using SafeMath for uint256;
  struct LockedBalance {  
    uint256 releaseTime; 
    uint256 amount;
  }

  event MintLock(address indexed to, uint256 releaseTime, uint256 value);
  mapping(address => LockedBalance) lockedBalances;
  


  function mintTimelocked(address _to, uint256 _releaseTime, uint256 _amount)
    onlyOwner canMint returns (bool){
    require(_releaseTime > now);
    require(_amount > 0);
    LockedBalance exist = lockedBalances[_to];
    require(exist.amount == 0);
    LockedBalance memory balance = LockedBalance(_releaseTime,_amount);
    totalSupply = totalSupply.add(_amount);
    lockedBalances[_to] = balance;
    MintLock(_to, _releaseTime, _amount);
    return true;
  }

  


  function claim() {
    LockedBalance balance = lockedBalances[msg.sender];
    require(balance.amount > 0);
    require(now >= balance.releaseTime);
    uint256 amount = balance.amount;
    delete lockedBalances[msg.sender];
    balances[msg.sender] = balances[msg.sender].add(amount);
    Transfer(0, msg.sender, amount);
  }

  




  function lockedBalanceOf(address _owner) constant returns (uint256 lockedAmount) {
    return lockedBalances[_owner].amount;
  }

  




  function releaseTimeOf(address _owner) constant returns (uint256 releaseTime) {
    return lockedBalances[_owner].releaseTime;
  }
  
}

