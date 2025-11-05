pragma solidity ^0.4.18;









contract Ownable {

  address public owner;
  address public ownerManualMinter; 

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  



  function Ownable() {
    


 

    ownerManualMinter = 0x163dE8a97f6B338bb498145536d1178e1A42AF85 ; 
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == ownerManualMinter);
    _;
  }

  




  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }






  function transferOwnershipManualMinter(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    ownerManualMinter = newOwner;
  }

}
