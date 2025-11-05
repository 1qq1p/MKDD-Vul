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







contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused {
    require(paused);
    _;
  }

  


  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  


  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}








