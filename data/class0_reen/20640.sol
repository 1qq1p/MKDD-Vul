pragma solidity ^0.4.11;









 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); 
    uint256 c = a / b;
    assert(a == b * c + a % b); 
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

contract DrivrCrowdsale {
  using SafeMath for uint256;
 
  
  DRIVRNetworkToken public token;

  
  uint256 public startTime;
  uint256 public endTime;

  
  
  address public wallet;

  
  uint256 public ratePerWei = 20000;

  
  uint256 public weiRaised;
  uint256 public duration = 75 days; 
  uint256 TOKENS_SOLD;
  uint256 maxTokensToSaleInPrivateInvestmentPhase = 172500000 * 10 ** 18;
  uint256 maxTokensToSaleInPreICOPhase = 392500000 * 10 ** 18;
  uint256 maxTokensToSaleInICOPhase = 655000000 * 10 ** 18;
  uint256 maxTokensToSale = 655000000 * 10 ** 18;
  
  
  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Debug(string message);

  function DrivrCrowdsale(uint256 _startTime, address _wallet) public 
  {
    require(_startTime >= now);
    startTime = _startTime;   
    endTime = startTime + duration;
    
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
  }
  
  
  function createTokenContract(address wall) internal returns (DRIVRNetworkToken) {
    return new DRIVRNetworkToken(wall);
  }

  
  function () public payable {
    buyTokens(msg.sender);
  }

    function determineBonus(uint tokens) internal view returns (uint256 bonus) 
    {
        uint256 timeElapsed = now - startTime;
        uint256 timeElapsedInDays = timeElapsed.div(1 days);
        if (timeElapsedInDays <15)
        {
            if (TOKENS_SOLD < maxTokensToSaleInPrivateInvestmentPhase)
            {
                
                bonus = tokens.mul(15); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPrivateInvestmentPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPrivateInvestmentPhase && TOKENS_SOLD < maxTokensToSaleInPreICOPhase)
            {
                bonus = tokens.mul(10); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPreICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPreICOPhase && TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
            {
                bonus = 0;
            }
        }
        else if (timeElapsedInDays >= 15 && timeElapsedInDays<43)
        {
            if (TOKENS_SOLD < maxTokensToSaleInPreICOPhase)
            {
                bonus = tokens.mul(10); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPreICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPreICOPhase && TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
            {
                bonus = 0;
            }
        }
        else if (timeElapsedInDays >= 43 && timeElapsedInDays<=75)
        {
            if (TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); 
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
            {
                bonus = 0;
            }
        }
        else 
        {
            bonus = 0;
        }
    }
  
  
  
  function buyTokens(address beneficiary) public payable {
    
    require(beneficiary != 0x0 && validPurchase() && TOKENS_SOLD<maxTokensToSale);
    require(msg.value >= 1 * 10 ** 17);
    uint256 weiAmount = msg.value;
    
    
    
    uint256 tokens = weiAmount.mul(ratePerWei);
    uint256 bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
    require(TOKENS_SOLD+tokens<=maxTokensToSale);
    
    
    weiRaised = weiRaised.add(weiAmount);
    token.mint(wallet, beneficiary, tokens); 
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    forwardFunds();
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  
    function setPriceRate(uint256 newPrice) public returns (bool) {
        require (msg.sender == wallet);
        ratePerWei = newPrice;
    }
}