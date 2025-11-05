pragma solidity ^0.4.24;







contract OwnableMintable {
  address public owner;
  address public mintOwner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event MintOwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  



  constructor() public {
    owner = msg.sender;
    mintOwner = msg.sender;
  }

  

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  


  modifier onlyMintOwner() {
    require(msg.sender == mintOwner);
    _;
  }

  



  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  



  function transferMintOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit MintOwnershipTransferred(mintOwner, newOwner);
    mintOwner = newOwner;
  }

}







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
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

  function uint2str(uint i) internal pure returns (string){
      if (i == 0) return "0";
      uint j = i;
      uint length;
      while (j != 0){
          length++;
          j /= 10;
      }
      bytes memory bstr = new bytes(length);
      uint k = length - 1;
      while (i != 0){
          bstr[k--] = byte(48 + i % 10);
          i /= 10;
      }
      return string(bstr);
  }
 
  
}









