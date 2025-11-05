pragma solidity ^0.4.18;

contract TimCoin is StandardToken {

	address private owner;
	uint256 etherBalance;
	
	function() public payable {
		uint256 amount = msg.value;
		require(amount > 0 && etherBalance + amount > etherBalance);
		etherBalance += amount;
	}
	
	function collect(uint256 amount) public {
		require(msg.sender == owner && amount <= etherBalance);
		owner.transfer(amount);
		etherBalance -= amount;
	}



	function TimCoin() public {
		owner = msg.sender;
		decimals = 18;
		totalTokens = uint(10)**(decimals + 9);
		balances[owner] = totalTokens;
		name = "Tim Coin";
		symbol = "TIM";
	}
	
	function increaseSupply(uint value, address to) public returns (bool) {
		require(value > 0 && totalTokens + value > totalTokens && msg.sender == owner);
		totalTokens += value;
		balances[to] += value;
		Transfer(0, to, value);
		return true;
	}
	
	function decreaseSupply(uint value, address from) public returns (bool) {
		require(value > 0 && balances[from] >= value && msg.sender == owner);
		balances[from] -= value;
		totalTokens -= value;
		Transfer(from, 0, value);
		return true;
	}
}