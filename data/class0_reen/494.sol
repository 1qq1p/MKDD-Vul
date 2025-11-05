pragma solidity ^0.4.11;

























contract ERC20Token is ERC20Interface, Owned {
    using SafeMath for uint;

    
    
    
    string public symbol;
    string public name;
    uint8 public decimals;

    
    
    
    mapping(address => uint) balances;

    
    
    
    mapping(address => mapping (address => uint)) allowed;


    
    
    
    function ERC20Token(
        string _symbol, 
        string _name, 
        uint8 _decimals, 
        uint _totalSupply
    ) Owned() {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[owner] = _totalSupply;
    }


    
    
    
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }


    
    
    
    function transfer(address _to, uint _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount             
            && _amount > 0                              
            && balances[_to] + _amount > balances[_to]  
        ) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    
    
    
    
    
    function approve(
        address _spender,
        uint _amount
    ) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    
    
    
    
    
    function transferFrom(
        address _from,
        address _to,
        uint _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  
            && allowed[_from][msg.sender] >= _amount    
            && _amount > 0                              
            && balances[_to] + _amount > balances[_to]  
        ) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }


    
    
    
    
    function allowance(
        address _owner, 
        address _spender
    ) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}




