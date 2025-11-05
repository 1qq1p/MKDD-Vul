pragma solidity ^0.4.24;





contract Ownable {
    
    
    
    event OwnershipTransfer (address previousOwner, address newOwner);
    
    
    address owner;
    
    
    
    
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransfer(address(0), owner);
    }

    
    
    
    modifier onlyOwner() {
        require(
            msg.sender == owner, 
            "Function can only be called by contract owner"
        );
        _;
    }

    
    
    
    
    
    function transferOwnership(address _newOwner) public onlyOwner {
        
        require (
            _newOwner != address(0),
            "New owner address cannot be zero"
        );
        
        address oldOwner = owner;
        
        owner = _newOwner;
        
        emit OwnershipTransfer(oldOwner, _newOwner);
    }
}





