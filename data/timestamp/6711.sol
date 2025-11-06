pragma solidity ^0.4.4;



contract Token is Object, ERC20 {
    
    string public name;
    string public symbol;

    
    uint public totalSupply;

    
    uint8 public decimals;
    
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
 
    




    function balanceOf(address _owner) constant returns (uint256)
    { return balances[_owner]; }
 
    





    function allowance(address _owner, address _spender) constant returns (uint256)
    { return allowances[_owner][_spender]; }

    
    function Token(string _name, string _symbol, uint8 _decimals, uint _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[msg.sender] = _count;
    }
 
    






    function transfer(address _to, uint _value) returns (bool) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to]        += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    







    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var avail = allowances[_from][msg.sender]
                  > balances[_from] ? balances[_from]
                                    : allowances[_from][msg.sender];
        if (avail >= _value) {
            allowances[_from][msg.sender] -= _value;
            balances[_from] -= _value;
            balances[_to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    




    function approve(address _spender, uint256 _value) returns (bool) {
        allowances[msg.sender][_spender] += _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    



    function unapprove(address _spender)
    { allowances[msg.sender][_spender] = 0; }
}
