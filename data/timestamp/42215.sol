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






contract HDK_Crowdsale is Pausable {
  using SafeMath for uint256;

  
  ERC20 public token;

  
  address public wallet;

  
  uint256 public rate;

  
  uint256 public weiRaised;
  
  
  uint256 public cap;
  
  
  uint256 public minInvest;
  
  
  uint256 public openingTime;
  
  
  uint256 public closingTime;

  
  uint256 public duration;

  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function HDK_Crowdsale() public {
    rate = 10000;
    wallet = owner;
    token = ERC20(0x4df624B49Cb604992ef8ebB5250B96Ec256C7472);
    cap = 100000 * 1 ether;
    minInvest = 0.1 * 1 ether;
    duration = 90 days;
    openingTime = 0;  
    closingTime = 0;  
  }
  
  


  function start() public onlyOwner {
    openingTime = now;       
    closingTime =  now + duration;
  }

  
  
  

  


  function () external payable {
    buyTokens(msg.sender);
  }

  



  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    
    uint256 tokens = _getTokenAmount(weiAmount);

    
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _forwardFunds();
  }

  
  
  

  




  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
    require(_beneficiary != address(0));
    require(_weiAmount >= minInvest);
    require(weiRaised.add(_weiAmount) <= cap);
    require(now >= openingTime && now <= closingTime);
  }

  




  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

  




  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  




  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

  


  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  
  



  function capReached() public view returns (bool) {
    return weiRaised >= cap;
  }
  
  



  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }

  


  function withdrawTokens() public onlyOwner {
    uint256 unsold = token.balanceOf(this);
    token.transfer(owner, unsold);
  }
    
}