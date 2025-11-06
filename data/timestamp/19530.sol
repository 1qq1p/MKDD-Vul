pragma solidity ^0.4.25;
































contract SmartolutionInterface {
    struct User {
        uint value;
        uint index;
        uint atBlock;
    }

    mapping (address => User) public users; 
}