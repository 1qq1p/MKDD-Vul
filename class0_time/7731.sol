pragma solidity ^0.4.8;

contract YEARS is ERC20, SafeMath, Ownable {

    
  string public name;       
  string public symbol;
  uint8 public decimals;    
  string public version = 'v0.1'; 
  uint public initialSupply;
  uint public totalSupply;
  bool public locked;
  

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  
  modifier onlyUnlocked() {
    if (msg.sender != owner && locked) throw;
    _;
  }

  



  function YEARS() {
    
    locked = true;
    

    initialSupply = 10000000000000000;
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
    name = 'LIGHTYEARS';        
    symbol = 'LYS';                       
    decimals = 8;                        
  }

  function unlock() onlyOwner {
    locked = false;
  }

  function burn(uint256 _value) returns (bool){
    balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
    totalSupply = safeSub(totalSupply, _value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

  function transfer(address _to, uint _value) onlyUnlocked returns (bool) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyUnlocked returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

    
  function approveAndCall(address _spender, uint256 _value, bytes _extraData){    
      TokenSpender spender = TokenSpender(_spender);
      if (approve(_spender, _value)) {
          spender.receiveApproval(msg.sender, _value, this, _extraData);
      }
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
}