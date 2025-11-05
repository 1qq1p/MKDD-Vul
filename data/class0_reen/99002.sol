pragma solidity ^0.4.11;








contract IcoToken is SafeMath, StandardToken, Pausable {
  string public name;
  string public symbol;
  uint256 public decimals;
  string public version;
  address public icoContract;


  function IcoToken(
    string _name,
    string _symbol,
    uint256 _decimals,
    string _version
  )
  {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    version = _version;
  }

  function transfer(address _to, uint _value) whenNotPaused returns (bool success) {
    return super.transfer(_to,_value);
  }

  function approve(address _spender, uint _value) whenNotPaused returns (bool success) {
    return super.approve(_spender,_value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return super.balanceOf(_owner);
  }

  function setIcoContract(address _icoContract) onlyOwner {
    if (_icoContract != address(0)) {
      icoContract = _icoContract;
    }
  }

  function sell(address _recipient, uint256 _value) whenNotPaused returns (bool success) {
      assert(_value > 0);
      require(msg.sender == icoContract);

      balances[_recipient] += _value;
      totalSupply += _value;

      Transfer(0x0, owner, _value);
      Transfer(owner, _recipient, _value);
      return true;
  }

  function issue(address _recipient, uint256 _value) whenNotPaused onlyOwner returns (bool success) {
      assert(_value > 0);
      _value = _value * 10**decimals;

      balances[_recipient] += _value;
      totalSupply += _value;

      Transfer(0x0, owner, _value);
      Transfer(owner, _recipient, _value);
      return true;
  }

}


