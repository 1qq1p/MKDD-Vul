pragma solidity ^0.4.11;












pragma solidity ^0.4.10;

contract Owned {
    address public owner;
    
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    
    function Owned() {
        owner = msg.sender;
    }
}
