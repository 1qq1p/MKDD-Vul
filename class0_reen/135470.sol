pragma solidity ^0.4.16;

contract Owned {

    
    address public owner;
    address public ico;

    function Owned() {
        owner = msg.sender;
        ico = msg.sender;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyICO() {
        
        require(msg.sender == ico);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
    function transferIcoship(address _newIco) onlyOwner {
        ico = _newIco;
    }
}

