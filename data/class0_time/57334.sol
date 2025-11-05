pragma solidity ^0.4.25;

contract owned {
    address public owner;
    bool public paused;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier normal {
        require(!paused);
        _;
    }

    function upgradeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function setPaused(bool _paused) onlyOwner public {
        paused = _paused;
    }
}
