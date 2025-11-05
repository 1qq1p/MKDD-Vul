pragma solidity ^0.4.25;

contract GitmanIssue {

    address private mediator;
    address public parent; 
    string public owner;
    string public repository;
    string public issue;

    constructor (string ownerId, string repositoryId, string issueId, address mediatorAddress) public payable { 
        parent = msg.sender;
        mediator = mediatorAddress;
        owner = ownerId;
        repository = repositoryId;
        issue = issueId;
    }

    function resolve(address developerAddress) public {
        require (msg.sender == mediator, "sender not authorized");
        selfdestruct(developerAddress);
    }

    function recall() public {
        require (msg.sender == mediator, "sender not authorized");
        selfdestruct(parent);
    }
}
