pragma solidity ^0.4.18;

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public returns (bool){
        require(newOwner != 0x0);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }
}

library SafeMath {
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(a >= b);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}
