pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool private _paused = false;

  


  function paused() public view returns (bool) {
    return _paused;
  }

  


  modifier whenNotPaused() {
    require(!_paused, "Contract is paused.");
    _;
  }

  


  modifier whenPaused() {
    require(_paused, "Contract not paused.");
    _;
  }

  


  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

  


  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}
