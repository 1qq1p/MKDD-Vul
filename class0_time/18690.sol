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

contract Crowdsale is Ownable {
  using SafeMath for uint256;

  ERC20Token token;

  
  uint256 public startTime;
  uint256 public endTime;

  
  address wallet;

  
  uint256 public rate;

  
  uint256 public weiRaised;

  uint256 public maxWei;

  bool paused;

  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token, uint256 _maxWei) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));
    require(_maxWei > 0);

    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
    token = ERC20Token(_token);
    maxWei = _maxWei;
    paused = false;
  }

  




  function updateRate(uint256 _rate) public onlyOwner {
    rate = _rate;
  }

  




  function updateMaxWei(uint256 _maxWei) public onlyOwner {
    maxWei = _maxWei;
  }

  




  function updateWallet(address _newWallet) public onlyOwner {
    wallet = _newWallet;
  }

  




  function pauseSale(bool _flag) public onlyOwner {
    paused = _flag;
  }

  
  function () external payable {
    buyTokens(msg.sender);
  }

  
  function buyTokens(address beneficiary) public payable {
    require(paused == false);
    require(msg.value <= maxWei);
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    
    uint256 tokens = weiAmount.mul(rate);

    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}




