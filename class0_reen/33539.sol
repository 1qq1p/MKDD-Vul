pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
}    

interface tokenRecipient { function receiveApproval(address _from, uint32 _value, address _token, bytes _extraData) public; }
