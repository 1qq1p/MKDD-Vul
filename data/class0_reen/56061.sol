


pragma solidity ^0.4.16;




pragma solidity ^0.4.16;





pragma solidity ^0.4.16;





contract NuggetsToken is AbstractToken {
  


  uint constant INITIAL_SUPPLY = 10000000000e18;

  


  function NuggetsToken () {
    owner = msg.sender;
    accounts [owner] = INITIAL_SUPPLY;
    tokensCount = INITIAL_SUPPLY;
  }

  




  function name () constant returns (string result) {
    return "Nuggets";
  }

  




  function symbol () constant returns (string result) {
    return "NUG";
  }

  




  function decimals () constant returns (uint8 result) {
    return 18;
  }

  




  function totalSupply () constant returns (uint256 supply) {
    return tokensCount;
  }

  






  function transfer (address _to, uint256 _value) returns (bool success) {
    return frozen ? false : AbstractToken.transfer (_to, _value);
  }

  








  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success) {
    return frozen ? false : AbstractToken.transferFrom (_from, _to, _value);
  }

  












  function approve (address _spender, uint256 _currentValue, uint256 _newValue)
  returns (bool success) {
    if (allowance (msg.sender, _spender) == _currentValue)
      return approve (_spender, _newValue);
    else return false;
  }

  





  function burnTokens (uint256 _value) returns (bool success) {
    uint256 ownerBalance = accounts [msg.sender];
    if (_value > ownerBalance) return false;
    else if (_value > 0) {
      accounts [msg.sender] = safeSub (ownerBalance, _value);
      tokensCount = safeSub (tokensCount, _value);
      return true;
    } else return true;
  }

  





  function setOwner (address _newOwner) {
    require (msg.sender == owner);

    owner = _newOwner;
  }

  



  function freezeTransfers () {
    require (msg.sender == owner);

    if (!frozen) {
      frozen = true;
      Freeze ();
    }
  }

  



  function unfreezeTransfers () {
    require (msg.sender == owner);

    if (frozen) {
      frozen = false;
      Unfreeze ();
    }
  }

  


  event Freeze ();

  


  event Unfreeze ();

  


  uint256 tokensCount;

  


  address owner;

  


  bool frozen;
}