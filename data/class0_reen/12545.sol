pragma solidity ^0.4.23;
 























pragma solidity >=0.4.18;

contract VfSE_Lottery_2 is Ownable, usingOraclize {
  using SafeMath for uint256;
  address[] private players;
  address[] public winners;
  uint256[] public payments;
  uint256 private feeValue;
  address public lastWinner;
  address public authorizedToDraw;
  address[] private last10Winners = [0,0,0,0,0,0,0,0,0,0];  
  uint256 public lastPayOut;
  uint256 public amountRised;
  address public house;
  uint256 public round;
  uint256 public playValue;
  uint256 public roundEnds;
  uint256 public roundDuration = 1 days;
  bool public stopped;
  mapping (address => uint256) public payOuts;
  uint256 private _seed;
 
 
  function bitSlice(uint256 n, uint256 bits, uint256 slot) private pure returns(uint256) {
    uint256 offset = slot * bits;
    uint256 mask = uint256((2**bits) - 1) << offset;
    return uint256((n & mask) >> offset);
  }
 
  function maxRandom() private returns (uint256 randomNumber) {
    bytes32 myrng = oraclize_query("WolframAlpha", "random number between 1 and 2^64");
    _seed = uint256(keccak256(_seed, myrng));
    return _seed;
  }
 
 
  function random(uint256 upper) private returns (uint256 randomNumber) {
    return maxRandom() % upper;
  }
   
  function setHouseAddress(address _house) onlyOwner public {
    house = _house;
  }
 
  function setAuthorizedToDraw(address _authorized) onlyOwner public {
    authorizedToDraw = _authorized;
  }
 
  function setFee(uint256 _fee) onlyOwner public {
    feeValue = _fee;
  }
 
  function setPlayValue(uint256 _amount) onlyOwner public {
    playValue = _amount;
  }
 
  function stopLottery(bool _stop) onlyOwner public {
    stopped = _stop;
  }
 
  function produceRandom(uint256 upper) private returns (uint256) {
    uint256 rand = random(upper);
    
    return rand;
  }
 
  function getPayOutAmount() private view returns (uint256) {
    
    uint256 fee = amountRised.mul(feeValue).div(100);
    return (amountRised - fee);
  }
 
  function draw() private {
    require(now > roundEnds);
    uint256 howMuchBets = players.length;
    uint256 k;
    lastWinner = players[produceRandom(howMuchBets)];
    lastPayOut = getPayOutAmount();
   
    winners.push(lastWinner);
    if (winners.length > 9) {
      for (uint256 i = (winners.length - 10); i < winners.length; i++) {
        last10Winners[k] = winners[i];
        k += 1;
      }
    }
 
    payments.push(lastPayOut);
    payOuts[lastWinner] += lastPayOut;
    lastWinner.transfer(lastPayOut);
   
    players.length = 0;
    round += 1;
    amountRised = 0;
    roundEnds = now + roundDuration;
   
    emit NewWinner(lastWinner, lastPayOut);
  }
 
  function drawNow() public {
    require(authorizedToDraw == msg.sender);
    draw();
  }
 
  function play() payable public {
    require (msg.value == playValue);
    require (!stopped);
 
    if (now > roundEnds) {
      if (players.length < 2) {
        roundEnds = now + roundDuration;
      } else {
        draw();
      }
    }
    players.push(msg.sender);
    amountRised = amountRised.add(msg.value);
  }
 
  function() payable public {
    play();
  }
 
  constructor() public {
    house = msg.sender;
    authorizedToDraw = msg.sender;
    feeValue = 10;
    playValue = 100 finney;
  }
   
  function getBalance() onlyOwner public {
    uint256 thisBalance = address(this).balance;
    house.transfer(thisBalance);
  }
 
  function getPlayersCount() public view returns (uint256) {
    return players.length;
  }
 
  function getWinnerCount() public view returns (uint256) {
    return winners.length;
  }
 
  function getPlayers() public view returns (address[]) {
    return players;
  }
 
  function last10() public view returns (address[]) {
    if (winners.length < 11) {
      return winners;
    } else {
      return last10Winners;
    }
  }
  event NewWinner(address _winner, uint256 _amount);
}