pragma solidity ^0.4.24;


contract StandardToken is ERC20, BasicToken{
  

  mapping (address => mapping (address => uint)) internal allowed;
  

  function transferFrom(address _from, address _to, uint _value) public returns (bool){
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    
    

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from,_to,_value);
    return true;

  }

  function approve(address _spender, uint _value) public returns (bool){
    allowed[msg.sender][_spender] = _value;
    
    emit Approval(msg.sender,_spender,_value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint){
    return allowed[_owner][_spender];
  }

  
  
  
  
  
  






















}

