pragma solidity 0.4.24;


contract Pausable is Ownable {
    
    event Pause();
    event Unpause();

    bool public paused = false;


    


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    


    modifier whenPaused() {
        require(paused);
        _;
    }

    


    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    


    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

library SafeMath64 {

  


  function mul(uint64 a, uint64 b) internal pure returns (uint64 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint64 a, uint64 b) internal pure returns (uint64) {
    
    
    
    return a / b;
  }

  


  function sub(uint64 a, uint64 b) internal pure returns (uint64) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint64 a, uint64 b) internal pure returns (uint64 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
