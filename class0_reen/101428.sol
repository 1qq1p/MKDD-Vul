pragma solidity ^0.4.13;








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





contract EmeraldToken is StandardToken, Ownable {

  string public name;
  string public symbol;
  uint public decimals;

  mapping (address => bool) public producers;

  bool public released = false;

  


  modifier onlyProducer() {
    require(producers[msg.sender] == true);
    _;
  }

  



  modifier canTransfer(address _sender) {
    if (_sender != owner)
      require(released);
    _;
  }

  modifier inProduction() {
    require(!released);
    _;
  }

  function EmeraldToken(string _name, string _symbol, uint _decimals) {
    require(_decimals > 0);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;

    
    producers[msg.sender] = true;
  }

  



  function setProducer(address _addr, bool _status) onlyOwner {
    producers[_addr] = _status;
  }

  


  function produceEmeralds(address _receiver, uint _amount) onlyProducer inProduction {
    balances[_receiver] = balances[_receiver].add(_amount);
    totalSupply = totalSupply.add(_amount);
    Transfer(0, _receiver, _amount);
  }

  


  function releaseTokenTransfer() onlyOwner {
    released = true;
  }

  function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool) {
    
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool) {
    
    return super.transferFrom(_from, _to, _value);
  }

}