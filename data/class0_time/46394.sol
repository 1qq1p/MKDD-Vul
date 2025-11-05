






























pragma solidity ^0.4.18;

contract EthFlip is usingOraclize {
    
  
  struct Bet {
    bool win;
    uint betValue;
    uint timestamp;
    address playerAddress;
    uint randomNumber;
  }
  
  
  struct Player {
    uint[] betNumbers;
  }
    
  
  struct QueryMap {
    uint betValue;
    address playerAddress;
  }
  
  
  bool private gamePaused;
  uint private minBet;
  uint private maxBet;
  uint private houseFee;
  uint private oraclizeGas;
  uint private oraclizeGasPrice;
  address private owner;
  
  
  uint private currentQueryId;
  uint private currentBetNumber;
  uint private totalPayouts;
  uint private totalWins;
  uint private totalLosses;

  
  bool private win;
  uint private randomNumber;
  mapping (address => Player) private playerBetNumbers;
  mapping (uint => Bet) private pastBets;
  mapping (uint => QueryMap) private queryIdMap;
  
  
  event BetComplete(bool _win, uint _betNumber, uint _betValue, uint _timestamp, address _playerAddress, uint _randomNumber);
  event GameStatusUpdate(bool _paused);
  event MinBetUpdate(uint _newMin);
  event MaxBetUpdate(uint _newMax);
  event HouseFeeUpdate(uint _newFee);
  event OwnerUpdate(address _newOwner);
  
  
  modifier gameIsActive {
    require(!gamePaused);
    _;
  }
  
  modifier gameIsNotActive {
    require(gamePaused);
    _;
  }
  
  modifier senderIsOwner {
    require(msg.sender == owner);
    _;
  }
  
  modifier senderIsOraclize {
    require(msg.sender == oraclize_cbAddress());
    _;
  }
  
  modifier sentEnoughForBet {
    require(msg.value >= minBet);
    _;
  }
  
  modifier didNotSendOverMaxBet {
    require(msg.value <= maxBet);
    _;
  }

  
  function EthFlip() public {
    minBet = 100000000000000000;
    maxBet = 500000000000000000;
    houseFee = 29; 
    oraclizeGas = 500000;
    oraclizeGasPrice = 3010000000;
    oraclize_setCustomGasPrice(oraclizeGasPrice);
    oraclize_setProof(proofType_Ledger);
    owner = msg.sender;
    
    
    totalPayouts = 1728380000000000000;
    totalWins = 10;
    totalLosses = 15;
  }
  
  
  function() public payable {}

  
  function placeBet() public payable gameIsActive sentEnoughForBet didNotSendOverMaxBet {
    secureGenerateNumber(msg.sender, msg.value);
  }
  
  
  function secureGenerateNumber(address _playerAddress, uint _betValue) private {
    bytes32 queryId = oraclize_newRandomDSQuery(0, 1, oraclizeGas);
    uint convertedId = uint(keccak256(queryId));
    queryIdMap[convertedId].betValue = _betValue;
    queryIdMap[convertedId].playerAddress = _playerAddress;
  }
  
  
  function checkIfWon() private {
    if (randomNumber != 101) {
      if (randomNumber <= 50) {
        win = true;
        sendPayout(subtractHouseFee(queryIdMap[currentQueryId].betValue*2));
      } else {
        win = false;
        sendOneWei();
      }
    } else {
      win = false;
      sendRefund();
    }
    logBet();
  }
  
  
  function sendPayout(uint _amountToPayout) private {
    uint payout = _amountToPayout;
    _amountToPayout = 0;
    queryIdMap[currentQueryId].playerAddress.transfer(payout);
  }
  
  
  function sendOneWei() private {
    queryIdMap[currentQueryId].playerAddress.transfer(1);
  }
  
  
  function sendRefund() private {
    queryIdMap[currentQueryId].playerAddress.transfer(queryIdMap[currentQueryId].betValue);
  }
  
  
  function subtractHouseFee(uint _amount) view private returns (uint _result) {
    return (_amount*(1000-houseFee))/1000;
  }
  
  function logBet() private {
    
    currentBetNumber++;
    if (win) {
      totalWins++;
      totalPayouts += subtractHouseFee(queryIdMap[currentQueryId].betValue*2);
    } else {
      if (randomNumber != 101) {
        totalLosses++;
      }
    }
    
    
    pastBets[currentBetNumber] = Bet({win:win, betValue:queryIdMap[currentQueryId].betValue, timestamp:block.timestamp, playerAddress:queryIdMap[currentQueryId].playerAddress, randomNumber:randomNumber});
    
    
    playerBetNumbers[queryIdMap[currentQueryId].playerAddress].betNumbers.push(currentBetNumber);
    
    
    BetComplete(win, currentBetNumber, queryIdMap[currentQueryId].betValue, block.timestamp, queryIdMap[currentQueryId].playerAddress, randomNumber);
    queryIdMap[currentQueryId].betValue = 0;
  }
  
  
  function getLastBetNumber() constant public returns (uint) {
    return currentBetNumber;
  }
  
  function getTotalPayouts() constant public returns (uint) {
    return totalPayouts;
  }
  
  function getTotalWins() constant public returns (uint) {
    return totalWins;
  }
  
  function getTotalLosses() constant public returns (uint) {
    return totalLosses;
  }
  
  
  function getBalance() constant public returns (uint) {
    return this.balance;
  }
  
  function getGamePaused() constant public returns (bool) {
      return gamePaused;
  }
  
  function getMinBet() constant public returns (uint) {
      return minBet;
  }
  
  function getMaxBet() constant public returns (uint) {
      return maxBet;
  }
  
  function getHouseFee() constant public returns (uint) {
      return houseFee;
  }
  
  function getOraclizeGas() constant public returns (uint) {
      return oraclizeGas;
  }
  
  function getOraclizeGasPrice() constant public returns (uint) {
      return oraclizeGasPrice;
  }
  
  function getOwnerAddress() constant public returns (address) {
      return owner;
  }
  
  function getPlayerBetNumbers(address _playerAddress) constant public returns (uint[] _betNumbers) {
    return (playerBetNumbers[_playerAddress].betNumbers);
  }
  
  function getPastBet(uint _betNumber) constant public returns (bool _win, uint _betValue, uint _timestamp, address _playerAddress, uint _randomNumber) {
    require(currentBetNumber >= _betNumber);
    return (pastBets[_betNumber].win, pastBets[_betNumber].betValue, pastBets[_betNumber].timestamp, pastBets[_betNumber].playerAddress, pastBets[_betNumber].randomNumber);
  }
  
  
  
  
  
  function pauseGame() public senderIsOwner gameIsActive {
    gamePaused = true;
    GameStatusUpdate(true);
  }
  
  function resumeGame() public senderIsOwner gameIsNotActive {
    gamePaused = false;
    GameStatusUpdate(false);
  }
  
  function setMaxBet(uint _newMax) public senderIsOwner gameIsNotActive {
    require(_newMax >= 100000000000000000);
    maxBet = _newMax;
    MaxBetUpdate(_newMax);
  }
  
  function setMinBet(uint _newMin) public senderIsOwner gameIsNotActive {
    require(_newMin >= 100000000000000000);
    minBet = _newMin;
    MinBetUpdate(_newMin);
  }
  
  function setHouseFee(uint _newFee) public senderIsOwner gameIsNotActive {
    require(_newFee <= 100);
    houseFee = _newFee;
    HouseFeeUpdate(_newFee);
  }
  
  function setOraclizeGas(uint _newGas) public senderIsOwner gameIsNotActive {
    oraclizeGas = _newGas;
  }
  
  function setOraclizeGasPrice(uint _newPrice) public senderIsOwner gameIsNotActive {
    oraclizeGasPrice = _newPrice + 10000000;
    oraclize_setCustomGasPrice(oraclizeGasPrice);
  }
  
  function setOwner(address _newOwner) public senderIsOwner gameIsNotActive {
    owner = _newOwner;
    OwnerUpdate(_newOwner);
  }
  
  function selfDestruct() public senderIsOwner gameIsNotActive {
    selfdestruct(owner);
  }
  
  
  
  
  
  function __callback(bytes32 _queryId, string _result, bytes _proof) public senderIsOraclize {
     currentQueryId = uint(keccak256(_queryId));
    if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
      randomNumber = (uint(keccak256(_result)) % 100) + 1;
    } else {
      randomNumber = 101;
    }
    if (queryIdMap[currentQueryId].betValue != 0) {
      checkIfWon();
    }
  }
}