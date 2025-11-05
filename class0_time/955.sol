pragma solidity ^0.4.17;

contract NovaCoinInterface {
  function consumeCoinForNova(address _from, uint _value) external {}
  function balanceOf(address _owner) public view returns (uint256 balance) {}
}
