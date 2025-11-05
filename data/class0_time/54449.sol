pragma solidity >=0.4.21;


library sMath {
    function multiply(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }


    function division(uint256 a, uint256 b) internal pure returns(uint256) {
        
        uint256 c = a / b;
        
        return c;
    }


    function subtract(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }


    function plus(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract StandardToken is ERC20{
    using sMath
    for uint256;

    mapping(address => uint256) balances;
    mapping(address => uint256) balances_crowd;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint256 totalSupply_;


    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balances[_from] >= _value);
        require(balances[_to].plus(_value) > balances[_to]);
        uint previousBalances = balances[_from].plus(balances[_to]);
        balances[_from] = balances[_from].subtract(_value);
        balances[_to] = balances[_to].plus(_value);
        emit Transfer(_from, _to, _value);
        assert(balances[_from].plus(balances[_to]) == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOfDef(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }
     
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner].plus(balances_crowd[_owner]);
    }
    
    function balanceOfCrowd(address _owner) public view returns(uint256 balance) {
        return balances_crowd[_owner];
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }


    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].plus(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.subtract(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}




