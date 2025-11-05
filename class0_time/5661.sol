pragma solidity ^0.4.23;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }

    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

contract Ownable {
  address public owner;
  address public admin;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  



  constructor() public {
    owner = msg.sender;
  }


  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyOwnerOrAdmin() {
    require(msg.sender != address(0) && (msg.sender == owner || msg.sender == admin));
    _;
  }

  



  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    require(newOwner != owner);
    require(newOwner != admin);

    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  function setAdmin(address newAdmin) onlyOwner public {
    require(admin != newAdmin);
    require(owner != newAdmin);

    admin = newAdmin;
  }
}
