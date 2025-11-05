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






contract INCXCrowdsale is CappedCrowdsale, FinalizableCrowdsale, WhitelistedCrowdsale, IndividualCapCrowdsale, MintedCrowdsale {
  event Refund(address indexed purchaser, uint256 tokens, uint256 weiReturned);
  event TokensReturned(address indexed owner, uint256 tokens);
  event EtherDepositedForRefund(address indexed sender,uint256 weiDeposited);
  event EtherWithdrawn(address indexed wallet,uint256 weiWithdrawn);
  
  uint256 public earlyBirdDuration;

  
  uint64 public constant decimals = 18;
  uint256 public constant oneHundredThousand = 100000 * 10**uint(decimals);
  uint256 public constant fiveHundredThousand = 500000 * 10**uint(decimals);
  uint256 public constant oneMillion = 1000000 * 10**uint(decimals);
  uint256 public constant twoMillionFourHundredThousand = 2400000 * 10**uint(decimals);
  uint256 public constant threeMillionTwoHundredThousand = 3200000 * 10**uint(decimals);


  function INCXCrowdsale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, address _wallet, uint256 _cap, INCXToken _token, uint256 _minAmount, uint256 _maxAmount, uint256 _earlyBirdDuration)
    public
    Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    TimedCrowdsale(_openingTime, _closingTime)
    IndividualCapCrowdsale(_minAmount, _maxAmount)
  {
    require(_earlyBirdDuration > 0);
    earlyBirdDuration = _earlyBirdDuration;
  }

  


  function finalization() internal {
    Ownable(token).transferOwnership(wallet);    
  }

  function isOpen() public view returns (bool) {
    return now >= openingTime;
  }

  


  function depositEtherForRefund() external payable {
    emit EtherDepositedForRefund(msg.sender, msg.value);
  }

  


  function withdraw() public onlyOwner {
    uint256 returnAmount = this.balance;
    wallet.transfer(returnAmount);
    emit EtherWithdrawn(wallet, returnAmount);
  }

  



  function refund(address _purchaser) public onlyOwner {
    uint256 amountToRefund = contributions[_purchaser];
    require(amountToRefund > 0);
    require(weiRaised >= amountToRefund);
    require(address(this).balance >= amountToRefund);
    contributions[_purchaser] = 0;
    uint256 _tokens = _getTokenAmount(amountToRefund);
    weiRaised = weiRaised.sub(amountToRefund);
    _purchaser.transfer(amountToRefund);
    emit Refund(_purchaser, _tokens, amountToRefund);
  }

  



  function setEarlyBirdDuration(uint256 _earlyBirdDuration) public onlyOwner {
    require(_earlyBirdDuration > 0);
    earlyBirdDuration = _earlyBirdDuration;
  }

  



  function setCap(uint256 _cap) public onlyOwner onlyWhileNotOpen {
    require(_cap > 0);
    cap = _cap;
  }

  




  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    uint256 _tokenAmount = _weiAmount.mul(rate);
    uint256 _bonus = 0;
    
    if(_tokenAmount >= oneHundredThousand && _tokenAmount < fiveHundredThousand) {
      _bonus = (_tokenAmount.mul(5)).div(100);
    } else if(_tokenAmount >= fiveHundredThousand && _tokenAmount < oneMillion) {
      _bonus = (_tokenAmount.mul(10)).div(100);
    } else if(_tokenAmount >= oneMillion && _tokenAmount < twoMillionFourHundredThousand) {
      _bonus = (_tokenAmount.mul(15)).div(100);
    } else if(_tokenAmount >= twoMillionFourHundredThousand && _tokenAmount < threeMillionTwoHundredThousand) {
      _bonus = (_tokenAmount.mul(20)).div(100);
    } else if(_tokenAmount >= threeMillionTwoHundredThousand){
      _bonus = (_tokenAmount.mul(25)).div(100);
    }
    _tokenAmount = _tokenAmount.add(_bonus);

    
    if(now.sub(openingTime) <= earlyBirdDuration) {
      _bonus = (_tokenAmount.mul(10)).div(100);
      _tokenAmount = _tokenAmount.add(_bonus);
    }  
    return _tokenAmount;
  }
}