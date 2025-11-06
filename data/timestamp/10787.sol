pragma solidity ^0.4.15;



contract Token is ERC20 {
  function () {
    
    require(false);
  }

  
  mapping(address => uint256) balances;

  
  mapping(address => mapping (address => uint256)) allowed;

  
  uint256 internal _totalSupply;

  
  
  function totalSupply() constant returns (uint256) {
    return _totalSupply;
  }

  
  
  
  function balanceOf(address _owner) constant returns (uint256) {
    return balances[_owner];
  }

  
  
  
  
  
  function transfer(address _to, uint256 _value) returns (bool) {
    require(balances[msg.sender] >= _value);
    require(_value > 0);
    require(balances[_to] + _value > balances[_to]);

    balances[msg.sender] -= _value;
    balances[_to]        += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  
  
  
  
  
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(balances[_from] >= _value);
    require(_value > 0);
    require(allowed[_from][msg.sender] >= _value);
    require(balances[_to] + _value > balances[_to]);

    balances[_from] -= _value;
    balances[_to]   += _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }

  
  
  
  
  
  
  
  function approve(address _spender, uint256 _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  
  
  
  
  function allowance(address _owner, address _spender) constant returns (uint256) {
    return allowed[_owner][_spender];
  }
}
