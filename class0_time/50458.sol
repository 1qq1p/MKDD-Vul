pragma solidity ^0.4.24;










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




contract UTP_ICO is Pausable {
  using SafeMath for uint256;

  
  ERC20 public token;

  
  address public wallet;

  
  uint256 public supply;

  
  uint256 public rate;

  
  uint256 public weiRaised;
  
  
  uint256 public openingTime;
  
  
  uint256 public closingTime;

  
  uint256 public duration;
  
  
  uint256 public minInvest;

  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  constructor() public {
    rate = 8000;
    wallet = owner;
    token = ERC20(0x2295F34b9c28Ddeac01Ee46073252CEA181fCCD1);
    duration = 365 days;
    minInvest = 0.1 * 1 ether;
    openingTime = 1591809475;  
    closingTime = openingTime + duration;  
  }
  
  


  function start(uint256 _duration) public onlyOwner {
    duration = _duration;
    openingTime = now;
    closingTime =  now + duration;
  }
  
  


  function changeRate(uint256 _rate) public onlyOwner {
    rate = _rate;
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
  
  



  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }

  


  function withdrawTokens() public onlyOwner {
    uint256 unsold = token.balanceOf(this);
    token.transfer(owner, unsold);
  }

}