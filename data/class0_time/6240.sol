pragma solidity ^0.4.17;




interface ERC20 {

  
  function transfer (address to, uint256 value) public returns (bool success);
  function transferFrom (address from, address to, uint256 value) public returns (bool success);
  function approve (address spender, uint256 value) public returns (bool success);
  function allowance (address owner, address spender) public constant returns (uint256 remaining);
  function balanceOf (address owner) public constant returns (uint256 balance);
  
  event Transfer (address indexed from, address indexed to, uint256 value);
  event Approval (address indexed owner, address indexed spender, uint256 value);
}



interface ERC165 {
  
  function supportsInterface(bytes4 interfaceID) external constant returns (bool);
}

contract InterfaceSignatureConstants {
  bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

  bytes4 constant InterfaceSignature_ERC20 =
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('allowance(address,address)'));

  bytes4 constant InterfaceSignature_ERC20_PlusOptions = 
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('decimals()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('allowance(address,address)'));
}
