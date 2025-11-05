pragma solidity ^0.4.19;

contract AVL is ERC20
{
    uint public incirculation;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    
    mapping (address => uint) goo;

    function transfer(address _to, uint _value) public returns (bool success)
    {
        uint gas = msg.gas;
        
        if (balances[msg.sender] >= _value && _value > 0)
        {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
          
            refund(gas+1158);
            
            return true;
        } 
        else
        {
            revert();
        }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success)
    {
        uint gas = msg.gas;

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0)
        {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            
            Transfer(_from, _to, _value);
          
            refund(gas);
            
            return true;
        }
        else
        {
            revert();
        }
    }

    function approve(address _spender, uint _value) public returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining)
    {
        return allowed[_owner][_spender];
    }
   
    function balanceOf(address _owner) public constant returns (uint balance)
    {
        return balances[_owner];
    }

    function totalSupply() public constant returns (uint totalsupply)
    {
        return incirculation;
    }
    
    function refund(uint gas) internal
    {
        uint amount = (gas-msg.gas+36120) * tx.gasprice;
        
        if (goo[msg.sender] < amount && goo[msg.sender] > 0)
        {
            amount = goo[msg.sender];
        }
        
        if (goo[msg.sender] >= amount)
        {
            goo[msg.sender] -= amount;
            
            msg.sender.transfer(amount);
        }
    }
}
