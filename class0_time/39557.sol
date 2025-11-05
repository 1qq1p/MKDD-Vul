contract Constants {
	uint256 public constant PRE_ICO_RISK_PERCENTAGE = 5;
	uint256 public constant TEAM_SHARE_PERCENTAGE = 16;
	uint256 public constant blocksByDay = 6306;
	uint256 public constant coinMultiplayer = (10**18);
	
	uint256 public constant PRICE_PREICO = 50000;
	uint256 public constant PRICE_ICO1 = 33333;
	uint256 public constant PRICE_ICO2 = 25000;
	uint256 public constant PRICE_ICO4 = 20000;
	
	uint256 public constant delayOfPreICO = blocksByDay*23;
	uint256 public constant delayOfICO1 = blocksByDay*46;
	uint256 public constant delayOfICO2 = blocksByDay*69;
	uint256 public constant delayOfICOEND = blocksByDay*90;
   uint256 public constant minimumGoal = coinMultiplayer*(10**6)*178 ;
  uint256 public constant maxTokenSupplyPreICO = coinMultiplayer*(10**6)*357 ; 
  uint256 public constant maxTokenSupplyICO1 = coinMultiplayer*(10**6)*595 ; 
  uint256 public constant maxTokenSupplyICO2 = coinMultiplayer*(10**6)*833 ; 
  uint256 public constant maxTokenSupplyICOEND =coinMultiplayer*(10**6)*1000 ; 
}


library SafeMath {
  function mul(uint256 a, uint256 b) constant public returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant public returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) constant public returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant public returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract DevTeamContractI{
	function recieveFunds() payable public;
}
