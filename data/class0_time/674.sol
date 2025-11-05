pragma solidity ^0.4.13;



library SafeMath {

    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function add(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

}



contract StandardToken is Token {

    function transfer(address _to, uint _value) returns (bool success) {
		require( msg.data.length >= (2 * 32) + 4 );
		require( _value > 0 );
		require( balances[msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
		require( msg.data.length >= (3 * 32) + 4 );
		require( _value > 0 );
		require( balances[_from] >= _value );
		require( allowed[_from][msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );

        balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns (bool success) {
		require( _value == 0 || allowed[msg.sender][_spender] == 0 );

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

}


