pragma solidity ^0.4.11;


contract owned {

    address public owner;
	
    function owned() payable { owner = msg.sender; }
    
    modifier onlyOwner { require(owner == msg.sender); _; }

 }


	