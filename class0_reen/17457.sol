






pragma solidity ^0.4.25;

contract Mortal is Owned {
	
	uint public closeAt;
	
	Token edg;
	
	function Mortal(address tokenContract) internal{
		edg = Token(tokenContract);
	}
	


  function closeContract(uint playerBalance) internal{
		if(closeAt == 0) closeAt = now + 30 days;
		if(closeAt < now || playerBalance == 0){
			edg.transfer(owner, edg.balanceOf(address(this)));
			selfdestruct(owner);
		} 
  }

	


	function open() onlyOwner public{
		closeAt = 0;
	}

	


	modifier isAlive {
		require(closeAt == 0);
		_;
	}

	


	modifier keepAlive {
		if(closeAt > 0) closeAt = now + 30 days;
		_;
	}
}
