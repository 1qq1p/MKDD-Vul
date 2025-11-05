pragma solidity ^0.4.13;

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    


    modifier whenNotPaused() {
        require(!paused || msg.sender == owner);

        _;
    }

    


    modifier whenPaused() {
        require(paused || msg.sender == owner);

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
