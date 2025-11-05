pragma solidity ^0.4.24;






contract Pausable is Ownable {
  event Pause(bool newState);
  event Unpause(bool newState);

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
    emit Pause(true);
  }

  


  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause(false);
  }
}
