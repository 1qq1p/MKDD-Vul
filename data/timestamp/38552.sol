


contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    if (halted) throw;
    _;
  }

  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }

  
  function halt() external onlyOwner {
    halted = true;
  }

  
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}









