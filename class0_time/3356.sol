pragma solidity ^0.4.18;

contract Manager {
    address public ceo;
    address public cfo;
    address public coo;
    address public cao;

    event OwnershipTransferred(address previousCeo, address newCeo);
    event Pause();
    event Unpause();


    



    function Manager() public {
        coo = msg.sender; 
        cfo = 0x7810704C6197aFA95e940eF6F719dF32657AD5af;
        ceo = 0x96C0815aF056c5294Ad368e3FBDb39a1c9Ae4e2B;
        cao = 0xC4888491B404FfD15cA7F599D624b12a9D845725;
    }

    


    modifier onlyCEO() {
        require(msg.sender == ceo);
        _;
    }

    modifier onlyCOO() {
        require(msg.sender == coo);
        _;
    }

    modifier onlyCAO() {
        require(msg.sender == cao);
        _;
    }
    
    bool allowTransfer = false;
    
    function changeAllowTransferState() public onlyCOO {
        if (allowTransfer) {
            allowTransfer = false;
        } else {
            allowTransfer = true;
        }
    }
    
    modifier whenTransferAllowed() {
        require(allowTransfer);
        _;
    }

    



    function demiseCEO(address newCeo) public onlyCEO {
        require(newCeo != address(0));
        emit OwnershipTransferred(ceo, newCeo);
        ceo = newCeo;
    }

    function setCFO(address newCfo) public onlyCEO {
        require(newCfo != address(0));
        cfo = newCfo;
    }

    function setCOO(address newCoo) public onlyCEO {
        require(newCoo != address(0));
        coo = newCoo;
    }

    function setCAO(address newCao) public onlyCEO {
        require(newCao != address(0));
        cao = newCao;
    }

    bool public paused = false;


    


    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    


    modifier whenPaused() {
        require(paused);
        _;
    }

    


    function pause() onlyCAO whenNotPaused public {
        paused = true;
        emit Pause();
    }

    


    function unpause() onlyCAO whenPaused public {
        paused = false;
        emit Unpause();
    }
}

