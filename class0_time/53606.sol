pragma solidity ^0.4.19;


contract Ownable {
    
    address public owner;

    


    function Ownable() public {
        owner = msg.sender;
    }

    


    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed from, address indexed to);

    




    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


