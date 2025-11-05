pragma solidity 0.5.7;

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

contract AntierToken is StandardToken, BurnableToken, ERC20Mintable {

    using SafeMath for uint;

    string constant public symbol = "ANTR";
    string constant public name = "Antier Token";

    uint8 constant public decimals = 8;
    uint256 public constant decimalFactor = 10 ** uint256(decimals);
    uint256 public constant INITIAL_SUPPLY = 1000000 * decimalFactor;

    constructor(address ownerAdrs) public {
        totalSupply_ = INITIAL_SUPPLY;
        
        preSale(ownerAdrs,totalSupply_);
    }

    function preSale(address _address, uint _amount) internal returns (bool) {
        balances[_address] = _amount;
        emit Transfer(address(0x0), _address, _amount);
    }

    
    function transfer(address _to, uint256 _value) isRunning public returns (bool) {
        super.transfer(_to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning public returns (bool) {
        super.transferFrom(_from, _to, _value);
        return true;
    }
    
}