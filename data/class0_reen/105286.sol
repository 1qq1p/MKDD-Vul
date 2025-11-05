pragma solidity 0.5.4;


contract Ownable {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    


    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    



    function transferOwnership(address newOwner) onlyOwner public {
        pendingOwner = newOwner;
    }

    


    function claimOwnership() onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

