pragma solidity ^0.4.24;






library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}







contract BCIOClaimable {
  address public owner;
  address public pendingOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  



  constructor() public {
    owner = msg.sender;
  }
  
  


  modifier onlyOwner() {
    require(msg.sender == owner, "Must be owner");
    _;
  }

  


  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner, "Must be pendingOwner");
    _;
  }

  



  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  


  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}





