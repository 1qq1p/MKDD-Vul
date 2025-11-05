contract BCFBaseCompetition {
    address public owner;
    address public referee;

    bool public paused = false;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyReferee() {
        require(msg.sender == referee);
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

    function setReferee(address newReferee) public onlyOwner {
        require(newReferee != address(0));
        referee = newReferee;
    }
    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    
    modifier whenPaused() {
        require(paused);
        _;
    }
    
    function pause() onlyOwner whenNotPaused public {
        paused = true;
    }
    
    function unpause() onlyOwner whenPaused public {
        paused = false;
    }
}

contract BCFMain {
    function isOwnerOfAllPlayerCards(uint256[], address) public pure returns (bool) {}
    function implementsERC721() public pure returns (bool) {}
    function getPlayerForCard(uint) 
        external
        pure
        returns (
        uint8,
        uint8,
        uint8,
        uint8,
        uint8,
        uint8,
        uint8,
        uint8,
        bytes,
        string,
        uint8
    ) {}
}








