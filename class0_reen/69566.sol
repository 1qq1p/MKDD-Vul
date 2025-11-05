pragma solidity ^0.4.11;
 
contract BitRS {

	mapping (address => uint256) public balanceOf;
	string public name;
	string public symbol;
	uint8 public decimal; 
	uint256 public intialSupply=500000000;
	uint256 public totalSupply;
	
	
	event Transfer(address indexed from, address indexed to, uint256 value);


	function BitRS(){
		balanceOf[msg.sender] = intialSupply;
		totalSupply = intialSupply;
		decimal = 0;
		symbol = "BitRS";
		name = "BitRS";
	}

	function transfer(address _to, uint256 _value){
		require(balanceOf[msg.sender] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]) ;
		

		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		Transfer(msg.sender, _to, _value);
	}

}
