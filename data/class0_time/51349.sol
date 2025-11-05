pragma solidity ^0.4.24;

contract LISCTrade is FrezeeableAccounts, Tradeable, LinkedToFiatTransform, InvestmentTransform, StartStopSell
{
  uint256 internal baseFiatPrice;
  uint256 public minBuyAmount;

  constructor(uint256 basePrice) public
  {
    baseFiatPrice = basePrice;
  }

  function setMinTrade(uint256 _minBuyAmount) onlyManager public
  {
    minBuyAmount = _minBuyAmount;
  }

  function priceInUSD() view public returns(uint256)
  {
    uint256 price = baseFiatPrice;
    price = fiatDrift(price);
    price = investmentRate(price);
    require(price > 0, "USD price cant be zero");
    return price;
  }

  function priceInETH() view public returns(uint256)
  {
    return FiatToEther(priceInUSD());
  }

  function tokensPerETH() view public returns(uint256)
  {
    uint256 EthPerToken = priceInETH();
    return deduceChange(denominator, EthPerToken);
  }

  function buy(string comment) payable public canBuy notFrozen(msg.sender)
  {
    uint256 USDAmount = EtherToFiat(msg.value);
    require(USDAmount > minBuyAmount, "You cant buy lesser than min USD amount");
    _buy(msg.value, priceInETH(), comment);
  }

  function sell(uint256 tokenAmount, string comment) public canSell notFrozen(msg.sender)
  {
    _sell(tokenAmount, priceInETH(), comment);
  }
}

