pragma solidity ^0.4.24;

contract TokenERC20 {
    using SafeMath for uint256;

    
    uint256 public totalSupply;

    
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    




    function balanceOf(address _owner) view public returns(uint256) {
        return balances[_owner];
    }

    





    function allowance(address _owner, address _spender) view public returns(uint256) {
        return allowed[_owner][_spender];
    }

    





    function _transfer(address _from, address _to, uint _value) internal {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer( _from, _to, _value);
    }

    






    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    







    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    






    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    







    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }

    





    function burn(uint256 _value) public returns(bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    






    function burnFrom(address _from, uint256 _value) public returns(bool) {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;
    }

    






    function transferMultiple(address[] _to, uint256[] _value) external returns(bool) {
        require(_to.length == _value.length);
        uint256 i = 0;
        while (i < _to.length) {
           _transfer(msg.sender, _to[i], _value[i]);
           i += 1;
        }
        return true;
    }
}




