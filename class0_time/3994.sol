pragma solidity ^0.4.16;






contract Crowdsale is Ownable {
    
  using SafeMath for uint;
    
  address multisig;

  uint restrictedPercent;

  address restricted;

  SimpleCoinToken public token = new SimpleCoinToken();

  uint start;
    
  uint period;

  uint rate;

  function Crowdsale() {
    multisig = 0x6F277a0c36184ad4D1C26Fdf8C97637c38733b29;
    restricted = 0x6F277a0c36184ad4D1C26Fdf8C97637c38733b29;
    restrictedPercent = 40;
    rate = 5000;
    start = 1511136000;
    period = 28;
  }

  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }

  function createTokens() saleIsOn payable {
    multisig.transfer(msg.value);
    uint tokens = rate.mul(msg.value).div(1 ether);
    uint bonusTokens = 0;
    if(now < start + (period * 1 days).div(4)) {
      bonusTokens = tokens.div(4);
    } else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
      bonusTokens = tokens.div(10);
    } else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
      bonusTokens = tokens.div(20);
    }
    uint tokensWithBonus = tokens.add(bonusTokens);
    token.transfer(msg.sender, tokensWithBonus);
    uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
    token.transfer(restricted, restrictedTokens);
  }

  function() external payable {
    createTokens();
  }
    
}