pragma solidity 0.4.12;














 
contract FILMToken is owned, token {

    mapping (address => bool) public frozenAccount;
    bool frozen = false; 
    event FrozenFunds(address target, bool frozen);

    function FILMToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) token (initialSupply, tokenName, decimalUnits, tokenSymbol) {}

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        if (frozenAccount[msg.sender]) throw;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[_from]) throw;
        if (balanceOf[_from] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        if (_value > allowance[_from][msg.sender]) throw;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }


    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function unfreezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = !freeze;
        FrozenFunds(target, !freeze);
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

    function burn(uint256 _value) public returns (bool success) {        
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);        
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {        
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);        
        return true;
    }
}