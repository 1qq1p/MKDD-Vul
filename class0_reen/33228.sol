pragma solidity ^0.4.16;


contract mortal is owned() {
  function kill() onlyOwner {
    if (msg.sender == owner) selfdestruct(owner);
  }
}
 


























