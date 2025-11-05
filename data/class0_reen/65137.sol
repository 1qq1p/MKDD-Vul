pragma solidity 0.4.24;


contract Pausable is Owned {
    bool public paused = false;
    event Pause();
    event Unpause();

    modifier notPaused {
        require(!paused);
        _;
    }

    function pause() public onlyOwner {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {
        paused = false;
        emit Unpause();
    }
}
