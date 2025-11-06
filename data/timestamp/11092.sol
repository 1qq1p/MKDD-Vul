pragma solidity ^0.4.19;









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







contract Ethbet {
  using SafeMath2 for uint256;

  



  event Deposit(address indexed user, uint amount, uint balance);

  event Withdraw(address indexed user, uint amount, uint balance);

  event LockedBalance(address indexed user, uint amount);

  event UnlockedBalance(address indexed user, uint amount);

  event ExecutedBet(address indexed winner, address indexed loser, uint amount);

  event RelayAddressChanged(address relay);


  


  address public relay;

  EthbetToken public token;

  mapping(address => uint256) balances;

  mapping(address => uint256) lockedBalances;

  



  modifier isRelay() {
    require(msg.sender == relay);
    _;
  }

  



  




  function Ethbet(address _relay, address _tokenAddress) public {
    
    require(_relay != address(0));

    relay = _relay;
    token = EthbetToken(_tokenAddress);
  }

  



  function setRelay(address _relay) public isRelay {
    
    require(_relay != address(0));

    relay = _relay;

    RelayAddressChanged(_relay);
  }

  



  function deposit(uint _amount) public {
    require(_amount > 0);

    
    
    require(token.transferFrom(msg.sender, this, _amount));

    
    balances[msg.sender] = balances[msg.sender].add(_amount);

    Deposit(msg.sender, _amount, balances[msg.sender]);
  }

  



  function withdraw(uint _amount) public {
    require(_amount > 0);
    require(balances[msg.sender] >= _amount);

    
    balances[msg.sender] = balances[msg.sender].sub(_amount);

    
    require(token.transfer(msg.sender, _amount));

    Withdraw(msg.sender, _amount, balances[msg.sender]);
  }


  




  function lockBalance(address _userAddress, uint _amount) public isRelay {
    require(_amount > 0);
    require(balances[_userAddress] >= _amount);

    
    balances[_userAddress] = balances[_userAddress].sub(_amount);

    
    lockedBalances[_userAddress] = lockedBalances[_userAddress].add(_amount);

    LockedBalance(_userAddress, _amount);
  }

  




  function unlockBalance(address _userAddress, uint _amount) public isRelay {
    require(_amount > 0);
    require(lockedBalances[_userAddress] >= _amount);

    
    lockedBalances[_userAddress] = lockedBalances[_userAddress].sub(_amount);

    
    balances[_userAddress] = balances[_userAddress].add(_amount);

    UnlockedBalance(_userAddress, _amount);
  }

  



  function balanceOf(address _userAddress) constant public returns (uint) {
    return balances[_userAddress];
  }

  



  function lockedBalanceOf(address _userAddress) constant public returns (uint) {
    return lockedBalances[_userAddress];
  }

  






  function executeBet(address _maker, address _caller, bool _makerWon, uint _amount) isRelay public {
    
    require(lockedBalances[_caller] >= _amount);

    
    require(lockedBalances[_maker] >= _amount);

    
    unlockBalance(_caller, _amount);

    
    unlockBalance(_maker, _amount);

    var winner = _makerWon ? _maker : _caller;
    var loser = _makerWon ? _caller : _maker;

    
    balances[winner] = balances[winner].add(_amount);
    
    balances[loser] = balances[loser].sub(_amount);

    
    ExecutedBet(winner, loser, _amount);
  }

}