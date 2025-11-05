pragma solidity ^0.4.18;




library SafeMath {
 
  function Mul(uint a, uint b) internal pure returns (uint) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function Div(uint a, uint b) internal pure returns (uint) {
    
    uint256 c = a / b;
    
    return c;
  }

  function Sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  } 

  function Add(uint a, uint b) internal pure returns (uint) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  } 
}




contract Ownable {

  
  address public owner;
  
  address oldOwner;

  
  function Ownable() public {
    owner = msg.sender;
    oldOwner = msg.sender;
  }

  
  modifier onlyOwner() {
    require (msg.sender == owner || msg.sender == oldOwner);
      _;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require (newOwner != address(0));
    owner = newOwner;
  }

}



