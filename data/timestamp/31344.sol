pragma solidity ^0.4.18;





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







contract PAD is StandardToken, Ownable {
    
    string  public constant name = "parabox token";
    string  public constant symbol = "PAD";
    uint8   public constant decimals = 2;
    uint256 public constant INITIAL_SUPPLY      = 4200000000 * (10 ** uint256(decimals));

    uint public amountRaised;
    uint256 public buyPrice = 50000;
    bool public crowdsaleClosed;
    
     function PAD() public {
      totalSupply_ = INITIAL_SUPPLY;
      balances[msg.sender] = INITIAL_SUPPLY;
      Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }

    function _transfer(address _from, address _to, uint _value) internal {     
        require (balances[_from] >= _value);               
        require (balances[_to] + _value > balances[_to]); 
   
        balances[_from] = balances[_from].sub(_value);                         
        balances[_to] = balances[_to].add(_value);                            
         
        Transfer(_from, _to, _value);
    }

    function setPrices(bool closebuy, uint256 newBuyPrice) onlyOwner public {
        crowdsaleClosed = closebuy;
        buyPrice = newBuyPrice;
    }

    function () external payable {
        require(!crowdsaleClosed);
        uint amount = msg.value ;               
        amountRaised = amountRaised.add(amount);
        _transfer(owner, msg.sender, amount.mul(buyPrice)); 
    }

    
    function safeWithdrawal(uint _value ) onlyOwner public {
       if (_value == 0) 
           owner.transfer(address(this).balance);
       else
           owner.transfer(_value);
    }

    
    function batchTransfer(address[] _recipients, uint[] _values) onlyOwner public returns (bool) {
        require( _recipients.length > 0 && _recipients.length == _values.length);

        uint total = 0;
        for(uint i = 0; i < _values.length; i++){
            total = total.add(_values[i]);
        }
        require(total <= balances[msg.sender]);

        for(uint j = 0; j < _recipients.length; j++){
            balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
            Transfer(msg.sender, _recipients[j], _values[j]);
        }

        balances[msg.sender] = balances[msg.sender].sub(total);
        return true;
    }
}