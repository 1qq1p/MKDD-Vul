pragma solidity ^0.4.25;





library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a && c >= b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }


}




contract Token is owned, TokenERC20  {

	
	uint256 _initialSupply=420000000; 
	string _tokenName="testdist";  
	string _tokenSymbol="tsdt";
	address wallet1 = 0x8012Eb27b9F5Ac2b74A975a100F60d2403365871;
	uint256 public startTime;

	mapping (address => bool) public frozenAccount;

	
	function Token( ) TokenERC20(_initialSupply, _tokenName, _tokenSymbol) public {

		startTime = now;

		balanceOf[wallet1] = totalSupply;

	}

	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != 0x0);

		uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
		balanceOf[_from] = balanceOf[_from].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
	}


}