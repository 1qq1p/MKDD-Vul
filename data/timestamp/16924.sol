pragma solidity 0.4.11;

contract IHubToken is ERC20Token, owned{
	using SafeMath for uint256;

	string public name = 'IHub TOKEN';
	string public symbol = 'IHT';
	uint8 public decimals = 4;
	uint256 public totalSupply = 500000000000;

	function IHubToken() public {
		balances[this] = totalSupply;
	}

	function setTokens(address target, uint256 _value) public onlyOwner {
		balances[this] = balances[this].sub(_value);
		balances[target] = balances[target].add(_value);
		Transfer(this, target, _value);
	}

	function mintToken(uint256 mintedAmount) public onlyOwner {
		totalSupply = totalSupply.add(mintedAmount);
		balances[this] = balances[this].add(mintedAmount);
	}
}