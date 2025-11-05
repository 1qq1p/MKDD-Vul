pragma solidity ^0.4.18;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}






contract Crowdsale is Ownable {
  using SafeMath for uint256;

  uint256   public constant rate = 1000;                  
  uint256   public constant cap = 1000000 ether;          

  bool      public isFinalized = false;

  uint256   public endTime = 1538351999;                   
                                                           

  CSCToken     public token;                                
  address       public wallet;                              
  uint256       public weiRaised;                           

  uint256   public firstBonus = 30;
  uint256   public secondBonus = 50;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Finalized();

  function Crowdsale (CSCToken _CSCT, address _wallet) public {
    assert(address(_CSCT) != address(0));
    assert(_wallet != address(0));
    assert(endTime > now);
    assert(rate > 0);
    assert(cap > 0);

    token = _CSCT;

    wallet = _wallet;
  }

  function () public payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = tokensForWei(weiAmount);
    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function getBonus(uint256 _tokens, uint256 _weiAmount) public view returns (uint256) {
    if (_weiAmount >= 30 ether) {
      return _tokens.mul(secondBonus).div(100);
    }
    return _tokens.mul(firstBonus).div(100);
  }

  function setFirstBonus(uint256 _newBonus) onlyOwner public {
    firstBonus = _newBonus;
  }

  function setSecondBonus(uint256 _newBonus) onlyOwner public {
    secondBonus = _newBonus;
  }

  function changeEndTime(uint256 _endTime) onlyOwner public {
    require(_endTime >= now);
    endTime = _endTime;
  }
  
  


  function finalize() onlyOwner public {
    require(!isFinalized);

    finalization();
    Finalized();

    isFinalized = true;
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal view returns (bool) {
    bool tokenMintingFinished = token.mintingFinished();
    bool withinCap = token.totalSupply().add(tokensForWei(msg.value)) <= cap;
    bool withinPeriod = now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    bool moreThanMinimumPayment = msg.value >= 0.1 ether;

    return !tokenMintingFinished && withinCap && withinPeriod && nonZeroPurchase && moreThanMinimumPayment;
  }

  function tokensForWei(uint weiAmount) public view returns (uint tokens) {
    tokens = weiAmount.mul(rate);
    tokens = tokens.add(getBonus(tokens, weiAmount));
  }

  function finalization() internal {
    token.finishMinting();
    endTime = now;
  }

  
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

}