pragma solidity ^ 0.4 .13;

contract Pausable is Ownable {
    bool public stopped;

    modifier stopInEmergency {
        if (stopped) {
            revert();
        }
        _;
    }

    modifier onlyInEmergency {
        if (!stopped) {
            revert();
        }
        _;
    }

    
    function emergencyStop() external onlyOwner {
        stopped = true;
    }

    
    function release() external onlyOwner onlyInEmergency {
        stopped = false;
    }
}






