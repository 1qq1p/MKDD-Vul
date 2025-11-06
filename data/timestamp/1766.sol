pragma solidity ^0.4.24;







library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}








contract GastroAdvisorToken is BaseToken {

  uint256 public lockedUntil;
  mapping(address => uint256) lockedBalances;
  string constant ROLE_OPERATOR = "operator";

  



  modifier canTransfer(address _from, uint256 _value) {
    require(mintingFinished || hasRole(_from, ROLE_OPERATOR));
    require(_value <= balances[_from].sub(lockedBalanceOf(_from)));
    _;
  }

  constructor(
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _cap,
    uint256 _lockedUntil
  )
  BaseToken(_name, _symbol, _decimals, _cap)
  public
  {
    lockedUntil = _lockedUntil;
    addMinter(owner);
    addOperator(owner);
  }

  function transfer(
    address _to,
    uint256 _value
  )
  public
  canTransfer(msg.sender, _value)
  returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
  public
  canTransfer(_from, _value)
  returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  




  function lockedBalanceOf(address _who) public view returns (uint256) {
    
    return block.timestamp <= lockedUntil ? lockedBalances[_who] : 0;
  }

  





  function mintAndLock(
    address _to,
    uint256 _amount
  )
  public
  hasMintPermission
  canMint
  returns (bool)
  {
    lockedBalances[_to] = lockedBalances[_to].add(_amount);
    return super.mint(_to, _amount);
  }

  



  function addOperator(address _operator) public onlyOwner {
    require(!mintingFinished);
    addRole(_operator, ROLE_OPERATOR);
  }

  



  function addOperators(address[] _operators) public onlyOwner {
    require(!mintingFinished);
    require(_operators.length > 0);
    for (uint i = 0; i < _operators.length; i++) {
      addRole(_operators[i], ROLE_OPERATOR);
    }
  }

  



  function removeOperator(address _operator) public onlyOwner {
    removeRole(_operator, ROLE_OPERATOR);
  }

  



  function addMinters(address[] _minters) public onlyOwner {
    require(_minters.length > 0);
    for (uint i = 0; i < _minters.length; i++) {
      addRole(_minters[i], ROLE_MINTER);
    }
  }
}







