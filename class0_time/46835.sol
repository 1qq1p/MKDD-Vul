pragma solidity ^0.4.19;
contract DTT is AccessControl{
  function approve(address _spender, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function balanceOf(address _addr) public returns (uint);
  mapping (address => mapping (address => uint256)) public allowance;
}
