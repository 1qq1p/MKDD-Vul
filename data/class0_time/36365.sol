pragma solidity ^0.4.23;





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






contract CrowdsaleToken is MintableToken {
  uint256 public cap = 300000000;
  uint256 public crowdSaleCap = 210000000;

  uint256 public basePrice = 15000000000000; 
  uint32 public privateSaleStartDate = 1526342400; 
  uint32 public privateSaleEndDate = 1529107199; 
  uint32 public preIcoStartDate = 1529107200; 
  uint32 public preIcoEndDate = 1531785599; 
  uint32 public icoStartDate = 1533081600; 
  uint32 public icoBonus1EndDate = 1533437999; 
  uint32 public icoBonus2EndDate = 1533945599; 
  uint32 public icoBonus3EndDate = 1534377599; 
  uint32 public icoBonus4EndDate = 1534809599; 
  uint32 public icoBonus5EndDate = 1535846399; 

  enum Stages {PrivateSale, PreIco, Ico}
  Stages currentStage;

  constructor() public {
    uint256 team = cap.sub(crowdSaleCap);
    balances[owner] = team;
    totalSupply_ = team;
    emit Transfer(address(this), owner, team);
    currentStage = Stages.PrivateSale;
  }

  function getStage () internal returns (uint8) {
    if (now > preIcoEndDate && currentStage != Stages.Ico) currentStage = Stages.Ico;
    if (now > privateSaleEndDate && now <= preIcoEndDate && currentStage != Stages.PreIco) currentStage = Stages.PreIco;
    return uint8(currentStage);
  }

  function getBonuses (uint256 _tokens) public returns (uint8) {
    uint8 _currentStage = getStage();
    if (_currentStage == 0) {
      if (_tokens > 70000) return 60;
      if (_tokens > 45000) return 50;
      if (_tokens > 30000) return 42;
      if (_tokens > 10000) return 36;
      if (_tokens > 3000) return 30;
      if (_tokens > 1000) return 25;
    }
    if (_currentStage == 1) {
      if (_tokens > 45000) return 45;
      if (_tokens > 30000) return 35;
      if (_tokens > 10000) return 30;
      if (_tokens > 3000) return 25;
      if (_tokens > 1000) return 20;
      if (_tokens > 25) return 15;
    }
    if (_currentStage == 2) {
      if (now <= icoBonus1EndDate) return 30;
      if (now <= icoBonus2EndDate) return 25;
      if (now <= icoBonus3EndDate) return 20;
      if (now <= icoBonus4EndDate) return 15;
      if (now <= icoBonus5EndDate) return 10;
    }
    return 0;
  }

  function mint (address _to, uint256 _amount) public returns (bool) {
    require(totalSupply_.add(_amount) <= cap);
    return super.mint(_to, _amount);
  }

  function () public payable {
    uint256 tokens = msg.value.div(basePrice);
    uint8 bonuses = getBonuses(tokens);
    uint256 extraTokens = tokens.mul(bonuses).div(100);
    tokens = tokens.add(extraTokens);
    require(totalSupply_.add(tokens) <= cap);
    owner.transfer(msg.value);
    balances[msg.sender] = balances[msg.sender].add(tokens);
    totalSupply_ = totalSupply_.add(tokens);
    emit Transfer(address(this), msg.sender, tokens);
  }
} 
