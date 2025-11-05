pragma solidity ^0.4.18;


contract owned {
    address public owner;
    address public candidate;

    function owned() payable internal {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) onlyOwner public {
        candidate = _owner;
    }

    function confirmOwner() public {
        require(candidate != address(0));
        require(candidate == msg.sender);
        owner = candidate;
        delete candidate;
    }
}


library SafeMath {
    function sub(uint256 a, uint256 b) pure internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function add(uint256 a, uint256 b) pure internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

