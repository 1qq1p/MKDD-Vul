pragma solidity ^0.4.19;





contract SunriseToken is BurnableToken, UpgradeableToken {

  string public name;
  string public symbol;
  uint public decimals;
  address public owner;

  mapping(address => uint) previligedBalances;

  function SunriseToken(address _owner, string _name, string _symbol, uint _totalSupply, uint _decimals)  UpgradeableToken(_owner) {
    name = _name;
    symbol = _symbol;
    totalSupply = _totalSupply;
    decimals = _decimals;

    
    balances[_owner] = _totalSupply;

    
    owner = _owner;
  }

  
  function transferPrivileged(address _to, uint _value) onlyPayloadSize(2 * 32) returns (bool success) {
    if (msg.sender != owner) throw;
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    previligedBalances[_to] = safeAdd(previligedBalances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function getPrivilegedBalance(address _owner) constant returns (uint balance) {
    return previligedBalances[_owner];
  }

  
  function transferFromPrivileged(address _from, address _to, uint _value) returns (bool success) {
    if (msg.sender != owner) throw;

    uint availablePrevilegedBalance = previligedBalances[_from];

    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    previligedBalances[_from] = safeSub(availablePrevilegedBalance, _value);
    Transfer(_from, _to, _value);
    return true;
  }
}
