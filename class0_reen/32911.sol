pragma solidity ^0.4.23;


contract ReentrancyGuard {

  


  bool private reentrancyLock = false;

  







  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

