pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





contract TotleControl is Ownable {
    mapping(address => bool) public authorizedPrimaries;

    
    modifier onlyTotle() {
        require(authorizedPrimaries[msg.sender]);
        _;
    }

    
    
    
    constructor(address _totlePrimary) public {
        authorizedPrimaries[_totlePrimary] = true;
    }

    
    
    
    function addTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = true;
    }

    function removeTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = false;
    }
}

