pragma solidity ^0.4.23;







contract Ownerable {
    
    
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    constructor() public { owner = msg.sender;}

    
    
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}








