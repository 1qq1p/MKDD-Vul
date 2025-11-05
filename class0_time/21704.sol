pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

contract BlockableContract is OwnableContract {
    
    event onBlockHODLs(bool status);
 
    bool public blockedContract;
    
    constructor() public { 
        blockedContract = false;  
    }
    
    modifier contractActive() {
        require(!blockedContract);
        _;
    } 
    
    function doBlockContract() onlyOwner public {
        blockedContract = true;
        
        emit onBlockHODLs(blockedContract);
    }
    
    function unBlockContract() onlyOwner public {
        blockedContract = false;
        
        emit onBlockHODLs(blockedContract);
    }
}
