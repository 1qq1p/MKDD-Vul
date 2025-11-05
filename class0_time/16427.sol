





















pragma solidity ^0.4.11;

contract owned {

    address public owner;
    address public candidate;

    function owned() public payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != 0);
        candidate = _owner;
    }
    
    function confirmOwner() public {
        require(candidate == msg.sender);
        owner = candidate;
        delete candidate;
    }
}




