pragma solidity ^0.4.11;

contract StandardToken is ERC20, SafeMath {
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  uint256 public _totalSupply;
  address public _creator;
  bool bIsFreezeAll = false;

  function totalSupply() constant returns (uint256 totalSupply) {
	totalSupply = _totalSupply;
  }

  function transfer(address _to, uint256 _value) returns (bool success) {
    require(bIsFreezeAll == false);
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    require(bIsFreezeAll == false);
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
	require(bIsFreezeAll == false);
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function freezeAll()
  {
	require(msg.sender == _creator);
	bIsFreezeAll = !bIsFreezeAll;
  }
}
