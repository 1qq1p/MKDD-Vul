pragma solidity ^0.4.0;








contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  function transferOwnership(address _newOwner)
      external
      onlyOwner {
      if (_newOwner == address(0x0)) throw;
      owner = _newOwner;
  }

}
