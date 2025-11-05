pragma solidity ^0.4.25;





contract Controlled {
    
    
    modifier onlyController { if (msg.sender != controller) revert(); _; }

    address public controller;

    constructor() { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}
