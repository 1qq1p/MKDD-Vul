pragma solidity ^0.4.23;

contract Owned {

    event OwnerChanged(address indexed from, address indexed to);

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function _transferOwnership(address _from, address _to) internal {
        owner = _to;
        emit OwnerChanged(_from, _to);
    }

    function transferOwnership(address newOwner) onlyOwner public {
        _transferOwnership(owner, newOwner);
    }
}
