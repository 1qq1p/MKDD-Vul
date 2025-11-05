pragma solidity ^0.4.24;

contract owned {

    address public owner;
    address public newOwner;

    constructor() public payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        newOwner = _owner;
    }

    function confirmOwner() public {
        require(newOwner == msg.sender);
        owner = newOwner;
    }
}
