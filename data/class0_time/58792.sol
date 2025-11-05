pragma solidity ^0.4.18;



contract Manageable {
  address public manager;


  



  function Manageable(address _manager) public {
    require(_manager != 0x0);
    manager = _manager;
  }

  


  modifier onlyManager() { 
    require (msg.sender == manager && manager != 0x0);
    _; 
  }
}


