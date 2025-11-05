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








contract BRFCrowdsale is RefundableCrowdsale {

  uint256[3] public icoStartTimes;
  uint256[3] public icoEndTimes;
  uint256[3] public icoRates;
  uint256[3] public icoCaps;
  uint256 public managementTokenAllocation;
  address public managementWalletAddress;
  uint256 public bountyTokenAllocation;
  address public bountyManagementWalletAddress;
  bool public contractInitialized = false;
  uint256 public constant MINIMUM_PURCHASE = 100;
  mapping(uint256 => uint256) public totalTokensByStage;
  bool public refundingComplete = false;
  uint256 public refundingIndex = 0;
  mapping(address => uint256) public directInvestors;
  mapping(address => uint256) public indirectInvestors;
  address[] private directInvestorsCollection;

  event TokenAllocated(address indexed beneficiary, uint256 tokensAllocated, uint256 amount);

  function BRFCrowdsale(
    uint256[3] _icoStartTimes,
    uint256[3] _icoEndTimes,
    uint256[3] _icoRates,
    uint256[3] _icoCaps,
    address _wallet,
    uint256 _goal,
    uint256 _managementTokenAllocation,
    address _managementWalletAddress,
    uint256 _bountyTokenAllocation,
    address _bountyManagementWalletAddress
    ) public
    Crowdsale(_icoStartTimes[0], _icoEndTimes[2], _icoRates[0], _wallet, new BRFToken())
    RefundableCrowdsale(_goal)
  {
    require((_icoCaps[0] > 0) && (_icoCaps[1] > 0) && (_icoCaps[2] > 0));
    require((_icoRates[0] > 0) && (_icoRates[1] > 0) && (_icoRates[2] > 0));
    require((_icoEndTimes[0] > _icoStartTimes[0]) && (_icoEndTimes[1] > _icoStartTimes[1]) && (_icoEndTimes[2] > _icoStartTimes[2]));
    require((_icoStartTimes[1] >= _icoEndTimes[0]) && (_icoStartTimes[2] >= _icoEndTimes[1]));
    require(_managementWalletAddress != owner && _wallet != _managementWalletAddress);
    require(_bountyManagementWalletAddress != owner && _wallet != _bountyManagementWalletAddress);
    icoStartTimes = _icoStartTimes;
    icoEndTimes = _icoEndTimes;
    icoRates = _icoRates;
    icoCaps = _icoCaps;
    managementTokenAllocation = _managementTokenAllocation;
    managementWalletAddress = _managementWalletAddress;
    bountyTokenAllocation = _bountyTokenAllocation;
    bountyManagementWalletAddress = _bountyManagementWalletAddress;
  }

  
  function () external payable {
    require(contractInitialized);
    buyTokens(msg.sender);
  }

  function initializeContract() public onlyOwner {
    require(!contractInitialized);
    allocateTokens(managementWalletAddress, managementTokenAllocation, 0, 0);
    allocateTokens(bountyManagementWalletAddress, bountyTokenAllocation, 0, 0);
    BRFToken brfToken = BRFToken(token);
    brfToken.setTransferAgent(managementWalletAddress, true);
    brfToken.setTransferAgent(bountyManagementWalletAddress, true);
    contractInitialized = true;
  }

  
  function allocateTokens(address beneficiary, uint256 tokensToAllocate, uint256 stage, uint256 rate) public onlyOwner {
    require(stage <= 5);
    uint256 tokensWithDecimals = toBRFWEI(tokensToAllocate);
    uint256 weiAmount = rate == 0 ? 0 : tokensWithDecimals.div(rate);
    weiRaised = weiRaised.add(weiAmount);
    if (weiAmount > 0) {
      totalTokensByStage[stage] = totalTokensByStage[stage].add(tokensWithDecimals);
      indirectInvestors[beneficiary] = indirectInvestors[beneficiary].add(tokensWithDecimals);
    }
    token.transfer(beneficiary, tokensWithDecimals);
    TokenAllocated(beneficiary, tokensWithDecimals, weiAmount);
  }

  function buyTokens(address beneficiary) public payable {
    require(contractInitialized);
    
    uint256 currTime = now;
    uint256 stageCap = toBRFWEI(getStageCap(currTime));
    rate = getTokenRate(currTime);
    uint256 stage = getStage(currTime);
    uint256 weiAmount = msg.value;
    uint256 tokenToGet = weiAmount.mul(rate);
    if (totalTokensByStage[stage].add(tokenToGet) > stageCap) {
      stage = stage + 1;
      rate = getRateByStage(stage);
      tokenToGet = weiAmount.mul(rate);
    }

    require((tokenToGet >= MINIMUM_PURCHASE));

    if (directInvestors[beneficiary] == 0) {
      directInvestorsCollection.push(beneficiary);
    }
    directInvestors[beneficiary] = directInvestors[beneficiary].add(tokenToGet);
    totalTokensByStage[stage] = totalTokensByStage[stage].add(tokenToGet);
    super.buyTokens(beneficiary);
  }

  function refundInvestors() public onlyOwner {
    require(isFinalized);
    require(!goalReached());
    require(!refundingComplete);
    for (uint256 i = 0; i < 20; i++) {
      if (refundingIndex >= directInvestorsCollection.length) {
        refundingComplete = true;
        break;
      }
      vault.refund(directInvestorsCollection[refundingIndex]);
      refundingIndex = refundingIndex.add(1);
    }
  }

  function advanceEndTime(uint256 newEndTime) public onlyOwner {
    require(!isFinalized);
    require(newEndTime > endTime);
    endTime = newEndTime;
  }

  function getTokenRate(uint256 currTime) public view returns (uint256) {
    return getRateByStage(getStage(currTime));
  }

  function getStageCap(uint256 currTime) public view returns (uint256) {
    return getCapByStage(getStage(currTime));
  }

  function getStage(uint256 currTime) public view returns (uint256) {
    if (currTime < icoEndTimes[0]) {
      return 0;
    } else if ((currTime > icoEndTimes[0]) && (currTime <= icoEndTimes[1])) {
      return 1;
    } else {
      return 2;
    }
  }

  function getCapByStage(uint256 stage) public view returns (uint256) {
    return icoCaps[stage];
  }

  function getRateByStage(uint256 stage) public view returns (uint256) {
    return icoRates[stage];
  }

  function allocateUnsold() internal {
    require(hasEnded());
    BRFToken brfToken = BRFToken(token);
    uint256 leftOverTokens = brfToken.balanceOf(address(this));
    if (leftOverTokens > 0) {
      token.transfer(owner, leftOverTokens);
    }
  }

  function toBRFWEI(uint256 value) internal view returns (uint256) {
    BRFToken brfToken = BRFToken(token);
    return (value * (10 ** uint256(brfToken.decimals())));
  }

  function finalization() internal {
    super.finalization();
    if (goalReached()) {
      allocateUnsold();
      BRFToken brfToken = BRFToken(token);
      brfToken.releaseTokenTransfer();
      brfToken.transferOwnership(owner);
    }
  }

}