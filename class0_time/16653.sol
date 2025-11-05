pragma solidity ^0.4.24;






contract EverGold is ERC827Token, MintableToken, AccessByGame {
  string public constant name = "Ever Gold";
  string public constant symbol = "EG";
  uint8 public constant decimals = 0;







  function mint(
    address _to,
    uint256 _amount
  )
    onlyAccessByGame
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
  function transfer(address _to, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {
    return super.approveAndCall(_spender, _value, _data);
  }

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {
    return super.transferAndCall(_to, _value, _data);
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {
    return super.transferFromAndCall(_from, _to, _value, _data);
  }

  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {
    return super.increaseApprovalAndCall(_spender, _addedValue, _data);
  }

  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {
    return super.decreaseApprovalAndCall(_spender, _subtractedValue, _data);
  }
}

library StringLib {
  function generateName(bytes16 _s, uint256 _len, uint256 _n)
    public
    pure
    returns (bytes16 ret)
  {
    uint256 v = _n;
    bytes16 num = 0;
    while (v > 0) {
      num = bytes16(uint(num) / (2 ** 8));
      num |= bytes16(((v % 10) + 48) * 2 ** (8 * 15));
      v /= 10;
    }
    ret = _s | bytes16(uint(num) / (2 ** (8 * _len)));
    return ret;
  }
}




