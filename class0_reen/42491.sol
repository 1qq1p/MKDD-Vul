pragma solidity ^0.4.18;










library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
    assert(c >= a);
    return c;
  }
}







contract JWCToken is ERC20BasicToken {
	using SafeMath for uint256;

	string public constant name      = "JWC Blockchain Ventures";   
	string public constant symbol    = "JWC";                       
	uint256 public constant decimals = 18;                          
	string public constant version   = "1.0";                       

	uint256 public constant tokenPreSale         = 100000000 * 10**decimals;
	uint256 public constant tokenPublicSale      = 400000000 * 10**decimals;
	uint256 public constant tokenReserve         = 300000000 * 10**decimals;
	uint256 public constant tokenTeamSupporter   = 120000000 * 10**decimals;
	uint256 public constant tokenAdvisorPartners = 80000000  * 10**decimals;

	address public icoContract;

	
	function JWCToken() public {
		totalSupply = tokenPreSale + tokenPublicSale + tokenReserve + tokenTeamSupporter + tokenAdvisorPartners;
	}

	



	function setIcoContract(address _icoContract) public onlyOwner {
		if (_icoContract != address(0)) {
			icoContract = _icoContract;
		}
	}

	




	function sell(address _recipient, uint256 _value) public whenNotPaused returns (bool success) {
		assert(_value > 0);
		require(msg.sender == icoContract);

		balances[_recipient] = balances[_recipient].add(_value);

		Transfer(0x0, _recipient, _value);
		return true;
	}

	




	function payBonusAffiliate(address _recipient, uint256 _value) public returns (bool success) {
		assert(_value > 0);
		require(msg.sender == icoContract);

		balances[_recipient] = balances[_recipient].add(_value);
		totalSupply = totalSupply.add(_value);

		Transfer(0x0, _recipient, _value);
		return true;
	}
}



