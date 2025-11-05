





















contract TokenVault is Ownable, Recoverable {
  using SafeMathLib for uint;

  
  uint public investorCount;

  
  uint public tokensToBeAllocated;

  
  uint public totalClaimed;

  
  uint public tokensAllocatedTotal;

  
  mapping(address => uint) public balances;

  
  mapping(address => uint) public claimed;

  
  uint public freezeEndsAt;

  
  uint public lockedAt;

  
  StandardTokenExt public token;

  





  enum State{Unknown, Loading, Holding, Distributing}

  
  event Allocated(address investor, uint value);

  
  event Distributed(address investors, uint count);

  event Locked();

  








  function TokenVault(address _owner, uint _freezeEndsAt, StandardTokenExt _token, uint _tokensToBeAllocated) {

    owner = _owner;

    
    if(owner == 0) {
      throw;
    }

    token = _token;

    
    if(!token.isToken()) {
      throw;
    }

    
    if(_freezeEndsAt == 0) {
      throw;
    }

    
    if(_tokensToBeAllocated == 0) {
      throw;
    }

    freezeEndsAt = _freezeEndsAt;
    tokensToBeAllocated = _tokensToBeAllocated;
  }

  
  function setInvestor(address investor, uint amount) public onlyOwner {

    if(lockedAt > 0) {
      
      throw;
    }

    if(amount == 0) throw; 

    
    if(balances[investor] > 0) {
      throw;
    }

    balances[investor] = amount;

    investorCount++;

    tokensAllocatedTotal += amount;

    Allocated(investor, amount);
  }

  
  
  
  
  function lock() onlyOwner {

    if(lockedAt > 0) {
      throw; 
    }

    
    if(tokensAllocatedTotal != tokensToBeAllocated) {
      throw;
    }

    
    if(token.balanceOf(address(this)) != tokensAllocatedTotal) {
      throw;
    }

    lockedAt = now;

    Locked();
  }

  
  function recoverFailedLock() onlyOwner {
    if(lockedAt > 0) {
      throw;
    }

    
    token.transfer(owner, token.balanceOf(address(this)));
  }

  
  
  function getBalance() public constant returns (uint howManyTokensCurrentlyInVault) {
    return token.balanceOf(address(this));
  }

  
  function claim() {

    address investor = msg.sender;

    if(lockedAt == 0) {
      throw; 
    }

    if(now < freezeEndsAt) {
      throw; 
    }

    if(balances[investor] == 0) {
      
      throw;
    }

    if(claimed[investor] > 0) {
      throw; 
    }

    uint amount = balances[investor];

    claimed[investor] = amount;

    totalClaimed += amount;

    token.transfer(investor, amount);

    Distributed(investor, amount);
  }

  
  function tokensToBeReturned(ERC20Basic _token) public returns (uint) {
    if (address(_token) == address(token))
      return getBalance().minus(tokensAllocatedTotal);
    else
      return token.balanceOf(this);
  }

  
  function getState() public constant returns(State) {
    if(lockedAt == 0) {
      return State.Loading;
    } else if(now > freezeEndsAt) {
      return State.Distributing;
    } else {
      return State.Holding;
    }
  }

}