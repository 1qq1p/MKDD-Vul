



pragma solidity ^0.5.4;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    address public distributionContract;

    bool distributionContractAdded;
    bool public paused = false;

    function addDistributionContract(address _contract) external {
        require(_contract != address(0));
        require(distributionContractAdded == false);

        distributionContract = _contract;
        distributionContractAdded = true;
    }

    modifier whenNotPaused() {
        if(msg.sender != distributionContract) {
            require(!paused);
        }
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}
