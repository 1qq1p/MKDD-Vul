pragma solidity 0.4.24;





library SafeMath {

  





  function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "Error: Unsafe multiplication operation!");
    return c;
  }

  





  function div(uint256 a, uint256 b) internal pure returns (uint256 result) {
    
    uint256 c = a / b;
    
    return c;
  }

  





  function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
    
    require(b <= a, "Error: Unsafe subtraction operation!");
    return a - b;
  }

  





  function add(uint256 a, uint256 b) internal pure returns (uint256 result) {
    uint256 c = a + b;
    require(c >= a, "Error: Unsafe addition operation!");
    return c;
  }
}




















contract Ownable {

  mapping(address => bool) public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AllowOwnership(address indexed allowedAddress);
  event RevokeOwnership(address indexed allowedAddress);

  



  constructor() public {
    owner[msg.sender] = true;
  }

  


  modifier onlyOwner() {
    require(owner[msg.sender], "Error: Transaction sender is not allowed by the contract.");
    _;
  }

  




  function transferOwnership(address newOwner) public onlyOwner returns (bool success) {
    require(newOwner != address(0), "Error: newOwner cannot be null!");
    emit OwnershipTransferred(msg.sender, newOwner);
    owner[newOwner] = true;
    owner[msg.sender] = false;
    return true;
  }

  




  function allowOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = true;
    emit AllowOwnership(allowedAddress);
    return true;
  }

  




  function removeOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = false;
    emit RevokeOwnership(allowedAddress);
    return true;
  }

}













































