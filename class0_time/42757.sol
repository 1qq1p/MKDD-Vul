pragma solidity 0.4.23;



contract MVLToken is BurnableToken, DetailedERC20, ERC20Token, TokenLock {
  using SafeMath for uint256;

  
  event Approval(address indexed owner, address indexed spender, uint256 value);

  string public constant symbol = "MVL";
  string public constant name = "Mass Vehicle Ledger Token";
  uint8 public constant decimals = 18;
  uint256 public constant TOTAL_SUPPLY = 3*(10**10)*(10**uint256(decimals));

  constructor() DetailedERC20(name, symbol, decimals) public {
    _totalSupply = TOTAL_SUPPLY;

    
    balances[owner] = _totalSupply;
    emit Transfer(address(0x0), msg.sender, _totalSupply);
  }

  
  
  modifier canTransfer(address _sender, uint256 _value) {
    require(_sender != address(0));
    require(
      (_sender == owner || _sender == admin) || (
        transferEnabled && (
          noTokenLocked ||
          canTransferIfLocked(_sender, _value)
        )
      )
    );

    _;
  }

  function setAdmin(address newAdmin) onlyOwner public {
    address oldAdmin = admin;
    super.setAdmin(newAdmin);
    approve(oldAdmin, 0);
    approve(newAdmin, TOTAL_SUPPLY);
  }

  modifier onlyValidDestination(address to) {
    require(to != address(0x0));
    require(to != address(this));
    require(to != owner);
    _;
  }

  function canTransferIfLocked(address _sender, uint256 _value) public view returns(bool) {
    uint256 after_math = balances[_sender].sub(_value);
    return after_math >= getMinLockedAmount(_sender);
  }

  
  function transfer(address _to, uint256 _value) onlyValidDestination(_to) canTransfer(msg.sender, _value) public returns (bool success) {
    return super.transfer(_to, _value);
  }

  
  function transferFrom(address _from, address _to, uint256 _value) onlyValidDestination(_to) canTransfer(_from, _value) public returns (bool success) {
    
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 

    
    emit Transfer(_from, _to, _value);

    return true;
  }

  function() public payable { 
    revert();
  }
}