pragma solidity ^0.4.24;





library SafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        assert(c / _a == _b);

        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        
        uint256 c = _a / _b;
        

        return c;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a);

        return c;
    }
}







contract BurnablePausableERC20Token is PausableERC20Token {

    mapping (address => mapping (address => uint256)) internal allowedBurn;

    event Burn(address indexed burner, uint256 value);

    event ApprovalBurn(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function allowanceBurn(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowedBurn[_owner][_spender];
    }

    function approveBurn(address _spender, uint256 _value) public returns (bool) {
        allowedBurn[msg.sender][_spender] = _value;
        emit ApprovalBurn(msg.sender, _spender, _value);
        return true;
    }

    



    function burn(
        uint256 _value
    ) 
        public
        whenNotPaused
    {
        _burn(msg.sender, _value);
    }

    




    function burnFrom(
        address _from, 
        uint256 _value
    ) 
        public 
        whenNotPaused
    {
        require(_value <= allowedBurn[_from][msg.sender]);
        
        
        allowedBurn[_from][msg.sender] = allowedBurn[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    function _burn(
        address _who, 
        uint256 _value
    ) 
        internal 
        whenNotPaused
    {
        require(_value <= balances[_who]);
        
        

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    function increaseBurnApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowedBurn[msg.sender][_spender] = (
        allowedBurn[msg.sender][_spender].add(_addedValue));
        emit ApprovalBurn(msg.sender, _spender, allowedBurn[msg.sender][_spender]);
        return true;
    }

    function decreaseBurnApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowedBurn[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowedBurn[msg.sender][_spender] = 0;
        } else {
            allowedBurn[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit ApprovalBurn(msg.sender, _spender, allowedBurn[msg.sender][_spender]);
        return true;
    }
}
