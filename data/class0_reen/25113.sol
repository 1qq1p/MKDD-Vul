



 
 pragma solidity ^0.4.10;
















contract Owned {
    address public owner;        

    function Owned() {
        owner = msg.sender;
    }

    
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        owner = _newOwner;
    }
}





