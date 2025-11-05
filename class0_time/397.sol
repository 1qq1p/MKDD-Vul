pragma solidity ^0.4.25;

contract Ownable {
  address public owner;

  



  constructor() public {
    owner = msg.sender;
  }


  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  



  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    
    owner = newOwner;
  }
  
    


    modifier isHuman() {
        address _addr = msg.sender;
        require (_addr == tx.origin);
        
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }


}
