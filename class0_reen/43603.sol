pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract WIZE is StandardToken, Ownable, Destructible, HasNoEther, HasNoTokens  {

	string public name = "WIZE";
	string public symbol = "WIZE";
	uint256 public decimals = 6;

	function WIZE() {
		balances[0x2D665c024bDeC12187cC96A7AcE22efFD3C40603] = 2000000E6;
		balances[0xDa8BE6E2F555a753d4B0DfF6B5518F262D097Bc7] = 98000000E6;
	}

}