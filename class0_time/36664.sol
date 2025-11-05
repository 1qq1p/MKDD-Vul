pragma solidity ^0.4.19;




library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
    }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract YeeLockerForYeeTeam {
    address public accountLocked;   
    uint256 public timeLockedStart;      
    uint256 public amountNeedToBeLock;  
    uint256 public unlockPeriod;      
    uint256 public unlockPeriodNum;   
    
    address  private yeeTokenAddress = 0x922105fAd8153F516bCfB829f56DC097a0E1D705;
    YEEToken private yeeToken = YEEToken(yeeTokenAddress);
    
    event EvtUnlock(address lockAccount, uint256 value);
    
    
    function _unlockOther(address otherTokenContract) public returns(bool result){
        if (otherTokenContract != yeeTokenAddress){
            StandardToken t = StandardToken(otherTokenContract);
            uint256 ava = t.balanceOf(this);
            if (ava <=0 ) return false;
            return t.transfer(accountLocked, ava);
        }
        return false;
    }
    
    function _balance() public view returns(uint256 amount){
        return yeeToken.balanceOf(this);
    }
    
    function unlockCurrentAvailableFunds() public returns(bool result){
        uint256 amount = getCurrentAvailableFunds();
        if ( amount == 0 ){
            return false;
        }
        else{
            bool ret = yeeToken.transfer(accountLocked, amount);
            EvtUnlock(accountLocked, amount);
            return ret;
        }
    }
    
    function getNeedLockFunds() public view returns(uint256 needLockFunds){
        uint256 count = (now - timeLockedStart)/unlockPeriod; 
        if ( count > unlockPeriodNum ){
            return 0;
        }
        else{
            uint256 needLock = amountNeedToBeLock / unlockPeriodNum * (unlockPeriodNum - count );
            return needLock;
        }
    }

    function getCurrentAvailableFunds() public view returns(uint256 availableFunds){
        uint256 balance = yeeToken.balanceOf(this);
        uint256 needLock = getNeedLockFunds();
        if ( balance > needLock ){
            return balance - needLock;
        }
        else{
            return 0;
        }
    }
    
    function getNeedLockFundsFromPeriod(uint256 endTime, uint256 startTime) public view returns(uint256 needLockFunds){
        uint256 count = (endTime - startTime)/unlockPeriod; 
        if ( count > unlockPeriodNum ){
            return 0;
        }
        else{
            uint256 needLock = amountNeedToBeLock / unlockPeriodNum * (unlockPeriodNum - count );
            return needLock;
        }
    }
    
    function YeeLockerForYeeTeam() public {
        
        
        accountLocked = msg.sender; 
        uint256 base = 1000000000000000000;
        amountNeedToBeLock = 1500000000 * base; 
        unlockPeriod = 30 days;
        unlockPeriodNum = 30;
        timeLockedStart = now;
    }
}