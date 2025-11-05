pragma solidity ^0.4.24;



contract BBZZXUCToken is StandardToken{

    string public name = "BBZZXUC";                                   
    uint256 public decimals = 18;                                 
    string public symbol = "BBZZXUC";                                 

    constructor() public {                    
        owner = msg.sender;
    }

    function () stoppable public {
        revert();
    }

}