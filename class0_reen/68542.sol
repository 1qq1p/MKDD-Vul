pragma solidity ^0.4.18;

contract AccessControl is Ownable {
    
    bool public paused = false;
    
    modifier whenPaused {
        require(paused);
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    
    function pause() external onlyOwner whenNotPaused {
        paused = true;
    }
    
    function unpause() external onlyOwner whenPaused {
        paused = false;
    }
    
}
