pragma solidity ^0.4.13;
contract owned {
  address public owner;

  function owned() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    owner = newOwner;
  }
}
