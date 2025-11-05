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
    
    
    
    return a / b;
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

contract AdvanceToken is StandardToken,Ownable{
    mapping (address => bool) public frozenAccount;
    
  event FrozenFunds(address target, bool frozen);
  
  function freezeAccount(address target, bool freeze)  public onlyOwner{
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
      require(_to != address(0));
      require(!frozenAccount[msg.sender]);

      require(balances[_from] >= _value);
      require(balances[ _to].add(_value) >= balances[ _to]);

      balances[_from] =balances[_from].sub(_value);
      balances[_to] =balances[_from].add(_value);

      emit Transfer(_from, _to, _value);
      return true;
  }
  
     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowed[_from][msg.sender] >= _value);
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        
        success =  _transfer(_from, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].add(_value);
  }

    

}
