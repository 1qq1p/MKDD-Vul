pragma solidity ^0.4.19;

interface tokenRecipient { 

    function receiveApproval(

        address _from, 

        uint256 _value,

        address _token, 

        bytes _extraData

    ) public; 

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract DRCToken is BurnableToken, MintableToken, PausableToken {    

    string public name = 'DRC Token';

    string public symbol = 'DRC';

    uint8 public decimals = 18;

    uint256 public INITIAL_SUPPLY = 1000000000000000000000000000;

    
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address _target, bool _frozen);

    




    function DRCToken() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
    }
    
    




    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        frozenAccount[_target] = _freeze;
        FrozenFunds(_target, _freeze);
    }

  




  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);
    return super.transfer(_to, _value);
  }
  
  





  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(!frozenAccount[_from]);
    return super.transferFrom(_from, _to, _value);
  }

  




  function transferMultiAddress(address[] _toMulti, uint256[] _values) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);
    assert(_toMulti.length == _values.length);

    uint256 i = 0;
    while ( i < _toMulti.length) {
        require(_toMulti[i] != address(0));
        require(_values[i] <= balances[msg.sender]);

        
        balances[msg.sender] = balances[msg.sender].sub(_values[i]);
        balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
        Transfer(msg.sender, _toMulti[i], _values[i]);

        i = i.add(1);
    }

    return true;
  }

  





  function transferMultiAddressFrom(address _from, address[] _toMulti, uint256[] _values) public whenNotPaused returns (bool) {
    require(!frozenAccount[_from]);
    assert(_toMulti.length == _values.length);
    
    uint256 i = 0;
    while ( i < _toMulti.length) {
        require(_toMulti[i] != address(0));
        require(_values[i] <= balances[_from]);
        require(_values[i] <= allowed[_from][msg.sender]);

        
        balances[_from] = balances[_from].sub(_values[i]);
        balances[_toMulti[i]] = balances[_toMulti[i]].add(_values[i]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_values[i]);
        Transfer(_from, _toMulti[i], _values[i]);

        i = i.add(1);
    }

    return true;
  }
  
    



    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }

    







    function burnFrom(address _from, uint256 _value) public whenNotPaused returns (bool success) {
        require(balances[_from] >= _value);                
        require(_value <= allowed[_from][msg.sender]);    
        balances[_from] = balances[_from].sub(_value);                         
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
    }

  





  function mint(address _to, uint256 _amount) onlyOwner canMint whenNotPaused public returns (bool) {
      return super.mint(_to, _amount);
  }

  



  function finishMinting() onlyOwner canMint whenNotPaused public returns (bool) {
      return super.finishMinting();
  }


    

















    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public whenNotPaused returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }

}