pragma solidity ^0.4.24;













contract Ownable {
    address public owner;


    



    function Ownable() public {
        owner = msg.sender;
    }


    


    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }


    



    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}









