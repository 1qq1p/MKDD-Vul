pragma solidity 0.4.23;



contract TokenLock is Ownable {
  using SafeMath for uint256;

  bool public transferEnabled = false; 
  bool public noTokenLocked = false; 

  struct TokenLockInfo { 
    uint256 amount; 
    uint256 time; 
  }

  struct TokenLockState {
    uint256 latestReleaseTime;
    TokenLockInfo[] tokenLocks; 
  }

  mapping(address => TokenLockState) lockingStates;
  event AddTokenLock(address indexed to, uint256 time, uint256 amount);

  function unlockAllTokens() public onlyOwner {
    noTokenLocked = true;
  }

  function enableTransfer(bool _enable) public onlyOwner {
    transferEnabled = _enable;
  }

  
  function getMinLockedAmount(address _addr) view public returns (uint256 locked) {
    uint256 i;
    uint256 a;
    uint256 t;
    uint256 lockSum = 0;

    
    TokenLockState storage lockState = lockingStates[_addr];
    if (lockState.latestReleaseTime < now) {
      return 0;
    }

    for (i=0; i<lockState.tokenLocks.length; i++) {
      a = lockState.tokenLocks[i].amount;
      t = lockState.tokenLocks[i].time;

      if (t > now) {
        lockSum = lockSum.add(a);
      }
    }

    return lockSum;
  }

  function addTokenLock(address _addr, uint256 _value, uint256 _release_time) onlyOwnerOrAdmin public {
    require(_addr != address(0));
    require(_value > 0);
    require(_release_time > now);

    TokenLockState storage lockState = lockingStates[_addr]; 
    if (_release_time > lockState.latestReleaseTime) {
      lockState.latestReleaseTime = _release_time;
    }
    lockState.tokenLocks.push(TokenLockInfo(_value, _release_time));

    emit AddTokenLock(_addr, _release_time, _value);
  }
}
