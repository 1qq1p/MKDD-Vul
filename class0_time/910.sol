pragma solidity ^0.4.11;

    
    
    
    
    
    
    

     
     
    
library SafeMath {

    
    
    
    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    
    
    
    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
}





contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }
 
    function acceptOwnership() {
        if (msg.sender == newOwner) {
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
    }
}





