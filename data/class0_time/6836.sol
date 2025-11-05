pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BurnToken is StandardToken {
    uint256 public initialSupply;

    event Burn(address indexed burner, uint256 value);
    
    constructor(uint256 _totalSupply) internal {
        initialSupply = _totalSupply;
    }

    function burnFunction(address _burner, uint256 _value) internal returns (bool) {
        require(_value > 0, "_value > 0");
		    require(_value <= balances[_burner], "_value <= balances[_burner]");

        balances[_burner] = balances[_burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_burner, _value);
        emit Transfer(_burner, address(0), _value);
		    return true;
    }
    
	function burn(uint256 _value) public returns(bool) {
        return burnFunction(msg.sender, _value);
    }

	function burnFrom(address _from, uint256 _value) public returns (bool) {
		require(_value <= allowed[_from][msg.sender], "_value <= allowed[_from][msg.sender]"); 
		burnFunction(_from, _value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		return true;
	}
}
