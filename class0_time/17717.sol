pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

library SafeMath {

  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    
     require(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    
    require(b > 0);
    uint256 c = a / b;
    
    require(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    
     require(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    
    require(c>=a && c>=b);
    return c;
  }







}
