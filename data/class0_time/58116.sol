pragma solidity 0.4.18;








contract EthicHubTokenDistributionStrategy is Ownable, WhitelistedDistributionStrategy {
  
  event UnsoldTokensReturned(address indexed destination, uint256 amount);


  function EthicHubTokenDistributionStrategy(EthixToken _token, uint256 _rate, uint256 _rateForWhitelisted)
           WhitelistedDistributionStrategy(_token, _rate, _rateForWhitelisted)
           public
  {

  }


  
  function initIntervals() onlyOwner validateIntervals  {

    
    require(owner == crowdsale.owner());

    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 1 days,10));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 2 days,10));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 3 days,8));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 4 days,6));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 5 days,4));
    bonusIntervals.push(BonusInterval(crowdsale.startTime() + 6 days,2));
  }

  function returnUnsoldTokens(address _wallet) onlyCrowdsale {
    
    if (token.balanceOf(this) == 0) {
      UnsoldTokensReturned(_wallet,0);
      return;
    }
    
    uint256 balance = token.balanceOf(this).sub(totalContributed);
    require(balance > 0);

    if(token.transfer(_wallet, balance)) {
      UnsoldTokensReturned(_wallet, balance);
    }
    
  } 
}