pragma solidity 0.4.21;

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

contract MegaCandy is StandardToken, LandAccessControl {

    string public constant name = "Unicorn Mega Candy"; 
    string public constant symbol = "Mega"; 
    uint8 public constant decimals = 18; 

    event Mint(address indexed _to, uint  _amount);


    


    function MegaCandy(address _landManagementAddress) LandAccessControl(_landManagementAddress) public {
    }

    function init() onlyLandManagement whenPaused external view {
    }

    function transferFromSystem(address _from, address _to, uint256 _value) onlyUnicornContract public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(address _from, uint256 _value) onlyUnicornContract public returns (bool) {
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        
        emit Burn(msg.sender, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }

    function mint(address _to, uint256 _amount) onlyCandyLand public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

}