pragma solidity ^0.4.0;

contract CrypteloERC20{
  mapping (address => uint256) public balanceOf;
  function transfer(address to, uint amount);
  function burn(uint256 _value) public returns (bool success);
}
