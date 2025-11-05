pragma solidity ^0.4.21;




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
  
  address deployer;

  
  function Ownable() public {
    owner = msg.sender;
    deployer = msg.sender;
  }

  
  modifier onlyOwner() {
    require (msg.sender == owner || msg.sender == deployer);
      _;
  }

  
  function transferOwnership(address _newOwner) public onlyOwner {
    require (_newOwner != address(0));
    owner = _newOwner;
  }

}




