pragma solidity ^0.4.24;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b); 
    return c;
  }
}

contract Ownable {

  address public owner;
  event SetOwner(address indexed oldOwner, address indexed newOwner);
  
  constructor() internal {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setOwner(address _newOwner) external onlyOwner {
    emit SetOwner(owner, _newOwner);
    owner = _newOwner;
  }
}
