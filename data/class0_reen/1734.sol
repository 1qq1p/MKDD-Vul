pragma solidity ^0.4.15;




























contract Controlled {
    
    
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    
    
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}
