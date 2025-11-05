pragma solidity 0.4.15;





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






contract PausableOnce is Ownable {

    
    address public pauseMaster;

    uint constant internal PAUSE_DURATION = 14 days;
    uint64 public pauseEnd = 0;

    event Paused();

    



    function setPauseMaster(address _pauseMaster) onlyOwner external returns (bool success) {
        require(_pauseMaster != address(0));
        pauseMaster = _pauseMaster;
        return true;
    }

    


    function pause() onlyPauseMaster external returns (bool success) {
        require(pauseEnd == 0);
        pauseEnd = uint64(now + PAUSE_DURATION);
        Paused();
        return true;
    }

    


    modifier whenNotPaused() {
        require(now > pauseEnd);
        _;
    }

    


    modifier onlyPauseMaster() {
        require(msg.sender == pauseMaster);
        _;
    }

}





