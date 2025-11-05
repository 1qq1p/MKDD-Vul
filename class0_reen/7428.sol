pragma solidity ^0.4.15;




contract Killable is Ownable {
  function kill() onlyOwner {
    selfdestruct(owner);
  }
}



