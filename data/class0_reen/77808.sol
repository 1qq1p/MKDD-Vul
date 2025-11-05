pragma solidity 0.5.3;




contract Stoppable {

  
  modifier onlyOwner { _; }
  

  bool public isOn = true;

  modifier whenOn() { require(isOn, "must be on"); _; }
  modifier whenOff() { require(!isOn, "must be off"); _; }

  function switchOff() external onlyOwner {
    if (isOn) {
      isOn = false;
      emit Off();
    }
  }
  event Off();
}



