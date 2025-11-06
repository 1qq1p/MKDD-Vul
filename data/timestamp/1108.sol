pragma solidity ^0.4.18;






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







contract ChronosBase is ChronosAccessControl {
    using SafeMath for uint256;
 
    
    bool public gameStarted;
    
    
    address public gameStarter;
    
    
    address public lastPlayer;
    
    
    uint256 public lastWagerTimeoutTimestamp;

    
    uint256 public timeout;
    
    
    
    uint256 public nextTimeout;
    
    
    uint256 public minimumTimeout;
    
    
    
    uint256 public nextMinimumTimeout;
    
    
    
    uint256 public numberOfWagersToMinimumTimeout;
    
    
    
    uint256 public nextNumberOfWagersToMinimumTimeout;
    
    
    uint256 public wagerIndex = 0;
    
    
    function calculateTimeout() public view returns(uint256) {
        if (wagerIndex >= numberOfWagersToMinimumTimeout || numberOfWagersToMinimumTimeout == 0) {
            return minimumTimeout;
        } else {
            
            
            uint256 difference = timeout - minimumTimeout;
            
            
            uint256 decrease = difference.mul(wagerIndex).div(numberOfWagersToMinimumTimeout);
            
            
            return (timeout - decrease);
        }
    }
}






