pragma solidity ^0.4.24;







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








contract ClinicAllCrowdsale is Crowdsale, FinalizableCrowdsale, MintedCrowdsale, ManagedWhitelist, Limited {
  constructor
  (
    uint256 _tokenLimitSupply,
    uint256 _rate,
    address _wallet,
    address _privateSaleWallet,
    ERC20 _token,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _discountTokenAmount,
    uint256 _discountTokenPercent,
    uint256 _preSaleClosingTime,
    uint256 _softCapLimit,
    ClinicAllRefundEscrow _vault,
    uint256 _buyLimitSupplyMin,
    uint256 _buyLimitSupplyMax,
    uint256 _kycLimitEliminator
  )
  Crowdsale(_rate, _wallet, _token)
  TimedCrowdsale(_openingTime, _closingTime)
  public
  {
    privateSaleWallet = _privateSaleWallet;
    tokenSupplyLimit = _tokenLimitSupply;
    discountTokenAmount = _discountTokenAmount;
    discountTokenPercent = _discountTokenPercent;
    preSaleClosingTime = _preSaleClosingTime;
    softCapLimit = _softCapLimit;
    vault = _vault;
    buyLimitSupplyMin = _buyLimitSupplyMin;
    buyLimitSupplyMax = _buyLimitSupplyMax;
    kycLimitEliminator = _kycLimitEliminator;
  }

  using SafeMath for uint256;

  
  ClinicAllRefundEscrow public vault;

  


  
  
  uint256 public tokenSupplyLimit;
  
  uint256 public discountTokenAmount;
  
  uint256 public discountTokenPercent;
  
  uint256 public preSaleClosingTime;
  
  uint256 public softCapLimit;
  
  uint256 public buyLimitSupplyMin;
  
  uint256 public buyLimitSupplyMax;
  
  uint256 public kycLimitEliminator;
  
  address public privateSaleWallet;
  
  uint256 public privateSaleSupplyLimit;

  

  



  function updateRate(uint256 _rate) public
  onlyManager
  {
    require(_rate != 0, "Exchange rate should not be 0.");
    rate = _rate;
  }

  




  function updateBuyLimitRange(uint256 _min, uint256 _max) public
  onlyOwner
  {
    require(_min != 0, "Minimal buy limit should not be 0.");
    require(_max != 0, "Maximal buy limit should not be 0.");
    require(_max > _min, "Maximal buy limit should be greater than minimal buy limit.");
    buyLimitSupplyMin = _min;
    buyLimitSupplyMax = _max;
  }

  



  function updateKycLimitEliminator(uint256 _value) public
  onlyOwner
  {
    require(_value != 0, "Kyc Eliminator should not be 0.");
    kycLimitEliminator = _value;
  }

  


  function claimRefund() public {
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");
    uint256 deposit = vault.depositsOf(msg.sender);
    vault.withdraw(msg.sender);
    weiRaised = weiRaised.sub(deposit);
    ClinicAllToken(token).burnAfterRefund(msg.sender);
  }

  



  function claimRefundChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner {
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");
    uint256 _weiRefunded;
    address[] memory _refundeesList;
    (_weiRefunded, _refundeesList) = vault.withdrawChunk(_txFee, _chunkLength);
    weiRaised = weiRaised.sub(_weiRefunded);
    for (uint256 i = 0; i < _refundeesList.length; i++) {
      ClinicAllToken(token).burnAfterRefund(_refundeesList[i]);
    }
  }


  


  function refundeesListLength() public onlyOwner view returns (uint256) {
    return vault.refundeesListLength();
  }

  



  function hasClosed() public view returns (bool) {
    return ((block.timestamp > closingTime) || tokenSupplyLimit <= token.totalSupply());
  }

  



  function goalReached() public view returns (bool) {
    return token.totalSupply() >= softCapLimit;
  }

  


  function supplyRest() public view returns (uint256) {
    return (tokenSupplyLimit.sub(token.totalSupply()));
  }

  

  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
  internal
  doesNotExceedLimit(_beneficiary, _tokenAmount, token.balanceOf(_beneficiary), kycLimitEliminator)
  {
    super._processPurchase(_beneficiary, _tokenAmount);
  }

  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
  internal
  onlyIfWhitelisted(_beneficiary)
  isLimited(_beneficiary)
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 tokens = _getTokenAmount(_weiAmount);
    require(tokens.add(token.totalSupply()) <= tokenSupplyLimit, "Total amount fo sold tokens should not exceed the total supply limit.");
    require(tokens >= buyLimitSupplyMin, "An investor can buy an amount of tokens only above the minimal limit.");
    require(tokens.add(token.balanceOf(_beneficiary)) <= buyLimitSupplyMax, "An investor cannot buy tokens above the maximal limit.");
  }

  




  function _getTokenAmount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    if (isDiscount()) {
      return _getTokensWithDiscount(_weiAmount);
    }
    return _weiAmount.mul(rate);
  }
  



  function getTokenAmount(uint256 _weiAmount)
  public view returns (uint256)
  {
    return _getTokenAmount(_weiAmount);
  }

  


  function _getTokensWithDiscount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    uint256 tokens = 0;
    uint256 restOfDiscountTokens = discountTokenAmount.sub(token.totalSupply());
    uint256 discountTokensMax = _getDiscountTokenAmount(_weiAmount);
    if (restOfDiscountTokens < discountTokensMax) {
      uint256 discountTokens = restOfDiscountTokens;
      
      uint256 _rate = _getDiscountRate();
      uint256 _discointWeiAmount = discountTokens.div(_rate);
      uint256 _restOfWeiAmount = _weiAmount.sub(_discointWeiAmount);
      uint256 normalTokens = _restOfWeiAmount.mul(rate);
      tokens = discountTokens.add(normalTokens);
    } else {
      tokens = discountTokensMax;
    }

    return tokens;
  }

  



  function _getDiscountTokenAmount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    require(_weiAmount != 0, "It should be possible to buy tokens only by providing non zero ETH.");
    uint256 _rate = _getDiscountRate();
    return _weiAmount.mul(_rate);
  }

  


  function _getDiscountRate()
  internal view returns (uint256)
  {
    require(isDiscount(), "Getting discount rate should be possible only below the discount tokens limit.");
    return rate.add(rate.mul(discountTokenPercent).div(100));
  }

  


  function getRate()
  public view returns (uint256)
  {
    if (isDiscount()) {
      return _getDiscountRate();
    }

    return rate;
  }

  


  function isDiscount()
  public view returns (bool)
  {
    return (preSaleClosingTime >= block.timestamp);
  }

  



  function transferTokensToReserve(address _beneficiary) private
  {
    require(tokenSupplyLimit < CappedToken(token).cap(), "Token's supply limit should be less that token' cap limit.");
    
    uint256 _tokenCap = CappedToken(token).cap();
    uint256 tokens = _tokenCap.sub(tokenSupplyLimit);

    _deliverTokens(_beneficiary, tokens);
  }

  


  function transferOn() public onlyOwner
  {
    ClinicAllToken(token).transferOn();
  }

  


  function transferOff() public onlyOwner
  {
    ClinicAllToken(token).transferOff();
  }

  


  function finalization() internal {
    if (goalReached()) {
      transferTokensToReserve(wallet);
      vault.close();
    } else {
      vault.enableRefunds();
    }
    MintableToken(token).finishMinting();
    super.finalization();
  }

  


  function _forwardFunds() internal {
    super._forwardFunds();
    vault.depositFunds(msg.sender, msg.value);
  }

  


  modifier onlyPrivateSaleWallet() {
    require(privateSaleWallet == msg.sender, "Wallet should be the same as private sale wallet.");
    _;
  }

  


  function transferToPrivateInvestor(
    address _beneficiary,
    uint256 _value
  )
  public
  onlyPrivateSaleWallet
  onlyIfWhitelisted(_beneficiary)
  returns (bool)
  {
    ClinicAllToken(token).transferToPrivateInvestor(msg.sender, _beneficiary, _value);
  }

  


  function redeemPrivateSaleFunds()
  public
  onlyPrivateSaleWallet
  {
    uint256 _balance = ClinicAllToken(token).balanceOf(msg.sender);
    privateSaleSupplyLimit = privateSaleSupplyLimit.sub(_balance);
    ClinicAllToken(token).burnPrivateSale(msg.sender, _balance);
  }

  



  function allocatePrivateSaleFunds(uint256 privateSaleSupplyAmount) public onlyOwner
  {
    require(privateSaleSupplyLimit.add(privateSaleSupplyAmount) < tokenSupplyLimit, "Token's private sale supply limit should be less that token supply limit.");
    privateSaleSupplyLimit = privateSaleSupplyLimit.add(privateSaleSupplyAmount);
    _deliverTokens(privateSaleWallet, privateSaleSupplyAmount);
  }

  



  function beneficiaryWithdrawChunk(uint256 _value) public onlyOwner {
    vault.beneficiaryWithdrawChunk(_value);
  }

  


  function beneficiaryWithdrawAll() public onlyOwner {
    vault.beneficiaryWithdrawAll();
  }

  



  function manualRefund(address _payee) public onlyOwner {

    uint256 deposit = vault.depositsOf(_payee);
    vault.manualRefund(_payee);
    weiRaised = weiRaised.sub(deposit);
    ClinicAllToken(token).burnAfterRefund(_payee);
  }

}