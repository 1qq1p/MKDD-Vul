pragma solidity ^0.4.4;
contract Owned{
	address owner;
	function Owned() public{
		owner = msg.sender;
	}
	modifier onlyOwner{
		require(msg.sender == owner);
		_;
	}
}