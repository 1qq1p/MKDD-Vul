pragma solidity ^0.4.25;
















contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    



    constructor() public {
        owner = msg.sender;
    }

    


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    



    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}




