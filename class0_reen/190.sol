pragma solidity ^0.4.13;

contract Token is IERC20Token, Owned {

  using SafeMath for uint256;

  
  string public standard;
  string public name;
  string public symbol;
  uint8 public decimals;

  address public crowdsaleContractAddress;

  
  uint256 supply = 0;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowances;

  
  event Mint(address indexed _to, uint256 _value);

  
  modifier onlyCrowdsaleOwner() {
      require(msg.sender == crowdsaleContractAddress);
      _;
  }

  
  function totalSupply() constant returns (uint256) {
    return supply;
  }

  
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  
  function transfer(address _to, uint256 _value) returns (bool success) {
    require(_to != 0x0 && _to != address(this));
    balances[msg.sender] = balances[msg.sender].sub(_value); 
    balances[_to] = balances[_to].add(_value);               
    Transfer(msg.sender, _to, _value);                       
    return true;
  }

  
  function approve(address _spender, uint256 _value) returns (bool success) {
    allowances[msg.sender][_spender] = _value;        
    Approval(msg.sender, _spender, _value);           
    return true;
  }

  
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    ItokenRecipient spender = ItokenRecipient(_spender);            
    approve(_spender, _value);                                      
    spender.receiveApproval(msg.sender, _value, this, _extraData);  
    return true;
  }

  
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    require(_to != 0x0 && _to != address(this));
    balances[_from] = balances[_from].sub(_value);                              
    balances[_to] = balances[_to].add(_value);                                  
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);  
    Transfer(_from, _to, _value);                                               
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowances[_owner][_spender];
  }

  function mintTokens(address _to, uint256 _amount) onlyCrowdsaleOwner {
    supply = supply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(msg.sender, _to, _amount);
  }

  function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner {
    IERC20Token(_tokenAddress).transfer(_to, _amount);
  }
}
