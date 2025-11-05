pragma solidity ^0.4.25;





contract Ownable {
  
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);
  
  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    assert(msg.sender == owner);
    _;
  }

  



  function transferOwnership(address _newOwner) public onlyOwner {
    assert(_newOwner != address(0));      
    newOwner = _newOwner;
  }

  


  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}




