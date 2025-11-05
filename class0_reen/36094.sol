pragma solidity ^0.4.11;









pragma solidity ^0.4.6;








contract Ownable {
  address public owner;


  



  function Ownable() {
    owner = msg.sender;
  }


  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  



  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}









pragma solidity ^0.4.6;











