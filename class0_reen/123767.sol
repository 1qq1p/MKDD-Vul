pragma solidity 0.5.7;






contract StandardToken is ERC20, BasicToken {
    uint public constant MAX_UINT = 2**256 - 1;

    mapping (address => mapping (address => uint256)) internal allowed;

    function burnFrom(address _owner, uint256 _value) public returns (bool) {
        require(_owner != address(0));
        require(_value <= balances[_owner]);
        require(_value <= allowed[_owner][msg.sender]);

        balances[_owner] = balances[_owner].sub(_value);
        if (allowed[_owner][msg.sender] < MAX_UINT) {
            allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_value);
        }
        totalSupply_ = totalSupply_.sub(_value);
        burnedTotalNum_ = burnedTotalNum_.add(_value);

        emit Burn(_owner, _value);
        return true;
    }

    





    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (_to == address(0)) {
            return burnFrom(_from, _value);
        }

        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        
        
        if (allowed[_from][msg.sender] < MAX_UINT) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
    









    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    





    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    









    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    









    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}
