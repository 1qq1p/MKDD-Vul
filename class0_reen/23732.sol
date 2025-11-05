pragma solidity ^0.4.24;

interface token {
    function transfer(address receiver, uint256 amount) external;
    function balanceOf(address _address) external returns(uint256);
}

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
