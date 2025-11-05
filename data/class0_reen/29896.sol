pragma solidity ^0.4.17;





contract Bitlagio is Ownable, usingOraclize {
  using SafeMath for uint;
  uint constant SAFE_GAS = 2300;
  uint constant ORACLIZE_GAS_LIMIT = 175000;
  uint constant N = 4;
  uint constant MODULO = 100;
  uint constant HOUSE_EDGE = 10;
  uint constant MIN_BET = 0.1 ether;
  struct Bet {
    address playerAddress;
    uint amountBet;
    uint numberRolled;
  }
  mapping(bytes32 => Bet) public bets;
  bytes32[] public betsKeys;
  
  uint maxBetAllowed;
  event LOG_NewBet(address playerAddress, uint amount);
  event LOG_BetWon(address playerAddress, uint numberRolled, uint amountWon);
  event LOG_BetLost(address playerAddress, uint numberRolled, uint amountLost);
  event LOG_OwnerDeposit(uint amount);
  event LOG_OwnerWithdraw(address destination, uint amount);
  modifier onlyIfBetSizeAllowed(uint betSize) {
    if (betSize > maxBetAllowed || betSize < MIN_BET) throw;
    _;
  }
  modifier onlyIfBetExist(bytes32 betId) {
    if(bets[betId].playerAddress == address(0x0)) throw;
    _;
  }
  modifier onlyIfNotProcessed(bytes32 betId) {
    if (bets[betId].numberRolled > 0) throw;
    _;
  }
  modifier onlyOraclize {
    if (msg.sender != oraclize_cbAddress()) throw;
    _;
  }
  function Bitlagio() public {
    oraclize_setNetwork(networkID_auto);
    
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
  }
  function adjustMaxBetAllowed() internal {
    maxBetAllowed = this.balance.div(10);
    if (maxBetAllowed > 10 ether) {
      maxBetAllowed = 10 ether;
    }
  }
  function () payable external {
    adjustMaxBetAllowed();
    if (msg.sender != owner) {
      makeBet(msg.value);
    } else {
      LOG_OwnerDeposit(msg.value);
    }
  }
  function makeBet(uint betSize) onlyIfBetSizeAllowed(betSize) {
    LOG_NewBet(msg.sender, betSize);
    uint delay = 0; 
    uint callbackGas = 200000; 
    bytes32 betId =
      oraclize_query(
        "nested",
        "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random.data.0', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BH/dtQ8XAz4lyFCzf4aAhI2mGO1GOCdtOLR2T2mBD/4mdQI+d6KT11xpL/m+vPDmTLp9LIX0NTlwsVkYf5p17BIPAruzez/uIctZLwuV/rT48i1sHw4UOW40R8Rsc+F3Wsv6dbKA8b7Qj1uPmgumSmG9gu4U},\"n\":1,\"min\":1,\"max\":100${[identity] \"}\"},\"id\":1${[identity] \"}\"}']",
        ORACLIZE_GAS_LIMIT + SAFE_GAS
      );
    bets[betId] = Bet(msg.sender, msg.value, 0);
    betsKeys.push(betId);
  }
  function __callback(bytes32 betId, string result, bytes proof) public
    onlyOraclize
    onlyIfBetExist(betId)
    onlyIfNotProcessed(betId)
  {
    bets[betId].numberRolled = parseInt(result);
    Bet thisBet = bets[betId];
    require(thisBet.numberRolled >= 1 && thisBet.numberRolled <= 100);
    if (betWon(thisBet)) {
      LOG_BetWon(thisBet.playerAddress, thisBet.numberRolled, thisBet.amountBet);
      thisBet.playerAddress.send(thisBet.amountBet.mul(2));
    } else {
      LOG_BetLost(thisBet.playerAddress, thisBet.numberRolled, thisBet.amountBet);
      thisBet.playerAddress.send(1);  
    }
  }
  function betWon(Bet bet) internal returns(bool) {
    if (bet.numberRolled > (MODULO.div(2).add(HOUSE_EDGE))) {
      return true;
    }
    return false;
  }
  function withdrawFromPot(uint amount) onlyOwner {
    LOG_OwnerWithdraw(owner, amount);
    owner.send(amount);
  }
}