
pragma solidity ^0.4.24;

contract AceDice is usingOraclize {
  
  
  
  
  
  uint constant HOUSE_EDGE_PERCENT = 2;
  uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0004 ether;
  
  
  
  uint constant MIN_JACKPOT_BET = 0.1 ether;
  
  
  uint constant JACKPOT_MODULO = 1000;
  uint constant JACKPOT_FEE = 0.001 ether;
  
  
  uint constant MIN_BET = 0.01 ether;
  uint constant MAX_AMOUNT = 300000 ether;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  uint constant MAX_MASK_MODULO = 40;
  
  
  uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;
  
  
  
  
  
  
  
  uint constant BET_EXPIRATION_BLOCKS = 250;
  
  
  
  address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  
  
  address public owner;
  address private nextOwner;
  
  
  uint public maxProfit;
  
  
  address public secretSigner;
  
  
  uint128 public jackpotSize;
  
  uint public todaysRewardSize;

  
  
  uint128 public lockedInBets;
  
  
  struct Bet {
    
    uint amount;
    
    
    
    
    uint8 rollUnder;
    
    uint40 placeBlockNumber;
    
    uint40 mask;
    
    address gambler;
    
    address inviter;
  }

  struct Profile{
    
    uint avatarIndex;
    
    string nickName;
  }
  
  
  mapping (bytes32 => Bet) bets;
  
  mapping (address => uint) accuBetAmount;

  mapping (address => Profile) profiles;
  
  
  address public croupier;
  
  
  event FailedPayment(address indexed beneficiary, uint amount);
  event Payment(address indexed beneficiary, uint amount, uint dice, uint rollUnder, uint betAmount);
  event JackpotPayment(address indexed beneficiary, uint amount, uint dice, uint rollUnder, uint betAmount);
  event VIPPayback(address indexed beneficiary, uint amount);
  
  
  event Commit(bytes32 commit);

  
  event TodaysRankingPayment(address indexed beneficiary, uint amount);
  
  
  constructor () public {
    owner = msg.sender;
    secretSigner = DUMMY_ADDRESS;
    croupier = DUMMY_ADDRESS;

    oraclize_setNetwork(networkID_auto);
    
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    
    oraclize_setCustomGasPrice(20000000000 wei);
  }
  
  
  modifier onlyOwner {
    require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
    _;
  }
  
  
  modifier onlyCroupier {
    require (msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
    _;
  }

    


    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }
  
  
  function approveNextOwner(address _nextOwner) external onlyOwner {
    require (_nextOwner != owner, "Cannot approve current owner.");
    nextOwner = _nextOwner;
  }
  
  function acceptNextOwner() external {
    require (msg.sender == nextOwner, "Can only accept preapproved new owner.");
    owner = nextOwner;
  }
  
  
  
  function () public payable {
  }
  
  
  function setSecretSigner(address newSecretSigner) external onlyOwner {
    secretSigner = newSecretSigner;
  }
  
  function getSecretSigner() external onlyOwner view returns(address){
    return secretSigner;
  }
  
  
  function setCroupier(address newCroupier) external onlyOwner {
    croupier = newCroupier;
  }
  
  
  function setMaxProfit(uint _maxProfit) public onlyOwner {
    require (_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
    maxProfit = _maxProfit;
  }
  
  
  function increaseJackpot(uint increaseAmount) external onlyOwner {
    require (increaseAmount <= address(this).balance, "Increase amount larger than balance.");
    require (jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
    jackpotSize += uint128(increaseAmount);
  }
  
  
  function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
    require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
    require (jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
    sendFunds(beneficiary, withdrawAmount, withdrawAmount, 0, 0, 0);
  }
  
  
  
  function kill() external onlyOwner {
    require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
    selfdestruct(owner);
  }

  
  function placeBet(uint betMask) external payable {
    
    
    uint amount = msg.value;
    
    require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
    
    
    
    
    
    uint mask;
    
    require (betMask > 2 && betMask <= 96, "High modulo range, betMask larger than modulo.");
    uint possibleWinAmount;
    uint jackpotFee;
    
    (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, betMask);
    
    
    require (possibleWinAmount <= amount + maxProfit, "maxProfit limit violation. ");
    
    
    lockedInBets += uint128(possibleWinAmount);
    jackpotSize += uint128(jackpotFee);
    
    
    require (jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

    bytes32 rngId = oraclize_query("WolframAlpha","random number between 1 and 1000");
    
    
    emit Commit(rngId);

    
    Bet storage bet = bets[rngId];
    bet.amount = amount;
    
    bet.rollUnder = uint8(betMask);
    bet.placeBlockNumber = uint40(block.number);
    bet.mask = uint40(mask);
    bet.gambler = msg.sender;
    
    uint accuAmount = accuBetAmount[msg.sender];
    accuAmount = accuAmount + amount;
    accuBetAmount[msg.sender] = accuAmount;
  }

  function placeBetWithInviter(uint betMask, address inviter) external payable {
     
    uint amount = msg.value;
    require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
    require (address(this) != inviter && inviter != address(0), "cannot invite myself");
    
    uint mask;
    
    require (betMask > 2 && betMask <= 96, "High modulo range, betMask larger than modulo.");
    uint possibleWinAmount;
    uint jackpotFee;
    
    (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, betMask);
    
    
    require (possibleWinAmount <= amount + maxProfit, "maxProfit limit violation. ");
    
    
    lockedInBets += uint128(possibleWinAmount);
    jackpotSize += uint128(jackpotFee);
    
    
    require (jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

    bytes32 rngId = oraclize_query("WolframAlpha","random number between 1 and 1000");
    
    
    emit Commit(rngId);

    
    Bet storage bet = bets[rngId];
    bet.amount = amount;
    
    bet.rollUnder = uint8(betMask);
    bet.placeBlockNumber = uint40(block.number);
    bet.mask = uint40(mask);
    bet.gambler = msg.sender;
    bet.inviter = inviter;
    
    uint accuAmount = accuBetAmount[msg.sender];
    accuAmount = accuAmount + amount;
    accuBetAmount[msg.sender] = accuAmount;
    
  }

  function __callback(bytes32 _rngId, string _result, bytes proof) onlyOraclize {
    Bet storage bet = bets[_rngId];
    require (bet.gambler != address(0), "cannot find bet info...");

    uint randomNumber = parseInt(_result);
    settleBetCommon(bet, randomNumber);
  }

    
  function settleBetCommon(Bet storage bet, uint randomNumber) private {
    
    uint amount = bet.amount;
    
    uint rollUnder = bet.rollUnder;
    address gambler = bet.gambler;
    
    
    require (amount != 0, "Bet should be in an 'active' state");

    applyVIPLevel(gambler, amount);
    
    
    bet.amount = 0;
    
    uint diceWinAmount;
    uint _jackpotFee;
    (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, rollUnder);
    
    uint diceWin = 0;
    uint jackpotWin = 0;

    uint dice = randomNumber / 10;
    

    
    if (dice < rollUnder) {
      diceWin = diceWinAmount;
    }
      
    
    lockedInBets -= uint128(diceWinAmount);
    
    
    if (amount >= MIN_JACKPOT_BET) {
      
      
      
      
      
      if (randomNumber == 0) {
        jackpotWin = jackpotSize;
        jackpotSize = 0;
      }
    }
    
    
    if (jackpotWin > 0) {
      emit JackpotPayment(gambler, jackpotWin, dice, rollUnder, amount);
    }
    
    if(bet.inviter != address(0)){
      
      
      bet.inviter.transfer(amount * HOUSE_EDGE_PERCENT / 100 * 15 /100);
    }
    todaysRewardSize += amount * HOUSE_EDGE_PERCENT / 100 * 9 /100;
    
    sendFunds(gambler, diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin, diceWin, dice, rollUnder, amount);
  }

  function applyVIPLevel(address gambler, uint amount) private {
    uint accuAmount = accuBetAmount[gambler];
    uint rate;
    if(accuAmount >= 30 ether && accuAmount < 150 ether){
      rate = 1;
    } else if(accuAmount >= 150 ether && accuAmount < 300 ether){
      rate = 2;
    } else if(accuAmount >= 300 ether && accuAmount < 1500 ether){
      rate = 4;
    } else if(accuAmount >= 1500 ether && accuAmount < 3000 ether){
      rate = 6;
    } else if(accuAmount >= 3000 ether && accuAmount < 15000 ether){
      rate = 8;
    } else if(accuAmount >= 15000 ether && accuAmount < 30000 ether){
      rate = 10;
    } else if(accuAmount >= 30000 ether && accuAmount < 150000 ether){
      rate = 12;
    } else if(accuAmount >= 150000 ether){
      rate = 15;
    } else{
      return;
    }

    uint vipPayback = amount * rate / 10000;
    if(gambler.send(vipPayback)){
      emit VIPPayback(gambler, vipPayback);
    }
  }

  function getMyAccuAmount() external view returns (uint){
    return accuBetAmount[msg.sender];
  }
  
      
  
  function getDiceWinAmount(uint amount, uint rollUnder) private pure returns (uint winAmount, uint jackpotFee) {
    require (0 < rollUnder && rollUnder <= 100, "Win probability out of range.");
    
    jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;
    
    uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;
    
    if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
      houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
    }
    
    require (houseEdge + jackpotFee <= amount, "Bet doesn't even cover house edge.");
    winAmount = (amount - houseEdge - jackpotFee) * 100 / rollUnder;
  }
      
  
  function sendFunds(address beneficiary, uint amount, uint successLogAmount, uint dice, uint rollUnder, uint betAmount) private {
    if (beneficiary.send(amount)) {
      emit Payment(beneficiary, successLogAmount, dice, rollUnder, betAmount);
    } else {
      emit FailedPayment(beneficiary, amount);
    }
  }
        

  function thisBalance() public view returns(uint) {
      return address(this).balance;
  }

  function setAvatarIndex(uint index) external{
    require (index >=0 && index <= 100, "avatar index should be in range");
    Profile storage profile = profiles[msg.sender];
    profile.avatarIndex = index;
  }

  function setNickName(string nickName) external{
    Profile storage profile = profiles[msg.sender];
    profile.nickName = nickName;
  }

  function getProfile() external view returns(uint, string){
    Profile storage profile = profiles[msg.sender];
    return (profile.avatarIndex, profile.nickName);
  }

  function payTodayReward(address to, uint rate) external onlyOwner {
    uint prize = todaysRewardSize * rate / 10000;
    todaysRewardSize = todaysRewardSize - prize;
    if(to.send(prize)){
      emit TodaysRankingPayment(to, prize);
    }
  }
}