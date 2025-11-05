pragma solidity ^0.4.25;






library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}








contract scaz is MintableToken, BurnableToken, PausableToken {

    string public constant name = "scaz";
    string public constant symbol = "SCAZ";
    uint8 public constant decimals =4;


    function scaz() {

    }


    

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        bool result = super.transferFrom(_from, _to, _value);
        return result;
    }

    mapping (address => bool) stopReceive;

    function setStopReceive(bool stop) {
        stopReceive[msg.sender] = stop;
    }

    function getStopReceive() constant public returns (bool) {
        return stopReceive[msg.sender];
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(!stopReceive[_to]);
        bool result = super.transfer(_to, _value);
        return result;
    }


    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        bool result = super.mint(_to, _amount);
        return result;
    }

    function burn(uint256 _value) public {
        super.burn(_value);
    }
   
    function pause() onlyOwner whenNotPaused public {
        super.pause();
    }
   
    function unpause() onlyOwner whenPaused public {
        super.unpause();
    }

    function transferAndCall(address _recipient, uint256 _amount, bytes _data) {
        require(_recipient != address(0));
        require(_amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);

        require(TokenRecipient(_recipient).tokenFallback(msg.sender, _amount, _data));
        Transfer(msg.sender, _recipient, _amount);
    }

}