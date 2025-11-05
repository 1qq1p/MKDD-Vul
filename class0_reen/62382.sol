pragma solidity ^0.4.24;







interface ERC165 {

  





  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}







contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    


    modifier whenPaused {
        require(paused);
        _;
    }

    


    function pause() external onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

    


    function unpause() external onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}
