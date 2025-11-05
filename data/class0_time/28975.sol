pragma solidity ^0.4.24;









contract Pausable is Ownable {

    event Paused();
    event Unpaused();

    bool public paused = false;


    


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    


    modifier whenPaused() {
        require(paused);
        _;
    }

    


    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused();
    }

    


    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused();
    }

}









