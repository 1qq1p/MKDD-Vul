pragma solidity 0.4.20;

































contract nbagame is usingOraclize {

  

  address owner;
  address public creator = 0x0161C8d35f0B603c7552017fe9642523f70d7B6A;
  address public currentOwner = 0x0161C8d35f0B603c7552017fe9642523f70d7B6A;

  uint8 public constant NUM_TEAMS = 2;
  string[NUM_TEAMS] public TEAM_NAMES = ["Golden State Warriors", "Washington Wizards"];
  enum TeamType { GSWarriors, WWizards, None }
  TeamType public winningTeam = TeamType.None;

  uint public constant TOTAL_POOL_COMMISSION = 10; 
  uint public constant EARLY_BET_INCENTIVE_COMMISSION = 4; 
  uint public constant OWNER_POOL_COMMISSION = 6; 
  
  uint public constant MINIMUM_BET = 0.01 ether; 

  uint public constant BETTING_OPENS = 1519599600; 
  uint public constant BETTING_CLOSES = 1519866300; 
  uint public constant PAYOUT_ATTEMPT_INTERVAL = 64800; 
  uint public constant BET_RELEASE_DATE = 1520039100; 
  uint public constant PAYOUT_DATE = BETTING_CLOSES + PAYOUT_ATTEMPT_INTERVAL; 
  
  uint public constant STAGE_ONE_BET_LIMIT = 0.2 ether; 
  

  bool public payoutCompleted;
  bool public stage2NotReached = true;
  
  struct Bettor {
    uint[NUM_TEAMS] amountsBet;
	uint[NUM_TEAMS] amountsBetStage1;
	uint[NUM_TEAMS] amountsBetStage2;
	
  }
  mapping(address => Bettor) bettorInfo;
  address[] bettors;
  uint[NUM_TEAMS] public totalAmountsBet;
  uint[NUM_TEAMS] public totalAmountsBetStage1;
  uint[NUM_TEAMS] public totalAmountsBetStage2;
  uint public numberOfBets;
  uint public totalBetAmount;
  
  
  
  uint public contractPrice = 0.05 ether;		
  
  uint private firstStepLimit = 0.1 ether;      
  uint private secondStepLimit = 0.5 ether;

  

  event BetMade();
  
  event ContractPurchased();
  
  

  
  
  
  modifier canPerformPayout() {
    if (winningTeam != TeamType.None && !payoutCompleted && now > BETTING_CLOSES) _;
  }

  
  
  modifier bettingIsClosed() {
    if (now > BETTING_CLOSES) _;
  }

  
  
  modifier onlyCreatorLevel() {
    require(
      creator == msg.sender
    );
    _;
  }
  
  
  
  
  function nbagame() public {
    owner = msg.sender;
    pingOracle(PAYOUT_DATE - now); 
  }

  
  
  function triggerRelease() public onlyCreatorLevel {
    require(now > BET_RELEASE_DATE);
    
    releaseBets();
  }

 
   
  function _addressNotNull(address _adr) private pure returns (bool) {
    return _adr != address(0);
  }
  
  function pingOracle(uint pingDelay) private {
    
    oraclize_query(pingDelay, "WolframAlpha", "Warriors vs Wizards February 28, 2018 Winner");
    
  }

  
  function __callback(bytes32 queryId, string result, bytes proof) public {
	
	  
    require(payoutCompleted == false);
    require(msg.sender == oraclize_cbAddress());
    
    
    
    
    
    if (keccak256(TEAM_NAMES[0]) == keccak256(result)) { 
      winningTeam = TeamType(0);
    }
    else if (keccak256(TEAM_NAMES[1]) == keccak256(result)) {
      winningTeam = TeamType(1);
    }
    
    
    
    if (winningTeam == TeamType.None) {    
      
      if (now >= BET_RELEASE_DATE)
        return releaseBets();
      return pingOracle(PAYOUT_ATTEMPT_INTERVAL);
    }
    
    performPayout();
  }

  
  function getUserBets() public constant returns(uint[NUM_TEAMS]) {    
    return bettorInfo[msg.sender].amountsBet;
  }

  
  function releaseBets() private {
    uint storedBalance = this.balance;
    for (uint k = 0; k < bettors.length; k++) {
      uint totalBet = SafeMath.add(bettorInfo[bettors[k]].amountsBet[0], bettorInfo[bettors[k]].amountsBet[1]);
      bettors[k].transfer(SafeMath.mul(totalBet, SafeMath.div(storedBalance, totalBetAmount)));
    }
  }
  
  
  function canBet() public constant returns(bool) {
    return (now >= BETTING_OPENS && now < BETTING_CLOSES);
  }
  
  
  function triggerPayout() public onlyCreatorLevel {
    pingOracle(5);
  }

  
  function bet(uint teamIdx) public payable {
    require(canBet() == true);
    require(TeamType(teamIdx) == TeamType.GSWarriors || TeamType(teamIdx) == TeamType.WWizards);
    require(msg.value >= MINIMUM_BET);

    
    if (bettorInfo[msg.sender].amountsBet[0] == 0 && bettorInfo[msg.sender].amountsBet[1] == 0)
      bettors.push(msg.sender);

	
	
	if (totalAmountsBet[teamIdx] >= STAGE_ONE_BET_LIMIT) {
		
		bettorInfo[msg.sender].amountsBetStage2[teamIdx] += msg.value;
		
		totalAmountsBetStage2[teamIdx] += msg.value;
	}
	
	
	if (totalAmountsBet[teamIdx] < STAGE_ONE_BET_LIMIT) {
		
		if (SafeMath.add(totalAmountsBet[teamIdx], msg.value) <= STAGE_ONE_BET_LIMIT) {
			bettorInfo[msg.sender].amountsBetStage1[teamIdx] += msg.value;
			
			totalAmountsBetStage1[teamIdx] += msg.value;
		} else {
			
			uint amountLeft = SafeMath.sub(STAGE_ONE_BET_LIMIT, totalAmountsBet[teamIdx]);
			uint amountExcess = SafeMath.sub(msg.value, amountLeft);
			
			bettorInfo[msg.sender].amountsBetStage1[teamIdx] += amountLeft;
			bettorInfo[msg.sender].amountsBetStage2[teamIdx] += amountExcess;
			
			totalAmountsBetStage1[teamIdx] = STAGE_ONE_BET_LIMIT;
			totalAmountsBetStage2[teamIdx] += amountExcess;
		}
	}
	
	
	



























	
    
    bettorInfo[msg.sender].amountsBet[teamIdx] += msg.value;
    numberOfBets++;
    totalBetAmount += msg.value;
    totalAmountsBet[teamIdx] += msg.value;
    BetMade(); 
  }

  
  
	  
  
  
  
  function performPayout() private canPerformPayout {
    
    
    uint losingChunk = SafeMath.sub(this.balance, totalAmountsBet[uint(winningTeam)]);
    uint currentOwnerPayoutCommission = uint256(SafeMath.div(SafeMath.mul(OWNER_POOL_COMMISSION, losingChunk), 100)); 
    uint eachStageCommission = uint256(SafeMath.div(SafeMath.mul(1, losingChunk), 100)); 
    
   
    
    
    for (uint k = 0; k < bettors.length; k++) {
      uint betOnWinner = bettorInfo[bettors[k]].amountsBet[uint(winningTeam)];
      uint payout = betOnWinner + ((betOnWinner * (losingChunk - currentOwnerPayoutCommission - (4 * eachStageCommission))) / totalAmountsBet[uint(winningTeam)]);
      
	  
	  
	  if (totalAmountsBetStage1[0] > 0) {
		  uint stageOneCommissionPayoutTeam0 = ((bettorInfo[bettors[k]].amountsBetStage1[0] * eachStageCommission) / totalAmountsBetStage1[0]);
		  payout += stageOneCommissionPayoutTeam0;
	  }
	  
	  if (totalAmountsBetStage1[1] > 0) {
		  uint stageOneCommissionPayoutTeam1 = ((bettorInfo[bettors[k]].amountsBetStage1[1] * eachStageCommission) / totalAmountsBetStage1[1]);
		  payout += stageOneCommissionPayoutTeam1;
	  }
	  
	  if (totalAmountsBetStage2[0] > 0) {
		  uint stageTwoCommissionPayoutTeam0 = ((bettorInfo[bettors[k]].amountsBetStage2[0] * eachStageCommission) / totalAmountsBetStage2[0]);
		  payout += stageTwoCommissionPayoutTeam0;
	  }
	  
	  if (totalAmountsBetStage2[1] > 0) {
		  uint stageTwoCommissionPayoutTeam1 = ((bettorInfo[bettors[k]].amountsBetStage2[1] * eachStageCommission) / totalAmountsBetStage2[1]);
		  payout += stageTwoCommissionPayoutTeam1;
	  }
	  
	  
	  if (payout > 0)
        bettors[k].transfer(payout);
    }
	
    currentOwner.transfer(currentOwnerPayoutCommission);
    
	
    if (this.balance > 0) {
        creator.transfer(this.balance);
        stage2NotReached = true;
    } else {
		stage2NotReached = false;
	}
	
    payoutCompleted = true;
  }

  function buyContract() public payable {
    address oldOwner = currentOwner;
    address newOwner = msg.sender;
  
    require(newOwner != oldOwner);
	require(_addressNotNull(newOwner));
	require(msg.value >= contractPrice);
	require(now < BETTING_CLOSES);
	
	
	uint payment = uint(SafeMath.div(SafeMath.mul(contractPrice, 94), 100));
	uint purchaseExcess = uint(SafeMath.sub(msg.value, contractPrice));
	uint creatorCommissionValue = uint(SafeMath.sub(contractPrice, payment));
	
	
	if (contractPrice < firstStepLimit) {
		
		contractPrice = SafeMath.div(SafeMath.mul(contractPrice, 132), 94);
	} else if (contractPrice < secondStepLimit) {
		
		contractPrice = SafeMath.div(SafeMath.mul(contractPrice, 122), 94);
	} else {
		
		contractPrice = SafeMath.div(SafeMath.mul(contractPrice, 113), 94);
	}
	
	
	currentOwner = newOwner;
	
	
	oldOwner.transfer(payment); 
	creator.transfer(creatorCommissionValue);
	
	ContractPurchased(); 
	
	msg.sender.transfer(purchaseExcess); 
  }
}

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