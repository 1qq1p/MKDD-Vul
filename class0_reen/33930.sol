pragma solidity ^0.4.24;































contract BetOnWorldCupFinal is Ownable, usingOraclize {
    using SafeMath for uint;
    string public homeTeam; 
    string public awayTeam; 
    bool public winningTeamSet;
    bool public winningTeam;
    bool public finalistTeamFIFAIdsSet;
    mapping(address => Bet) public bets;

    struct Bet {
      uint256 betValueHomeTeam;
      uint256 betValueAwayTeam;
    }

    uint256 public totalPotHomeTeam;
    uint256 public totalPotAwayTeam;

    event successfulBet(address indexed sender, bool team, uint256 value);
    event LogNewOraclizeQuery(string description);

    constructor() public payable {
        homeTeam ="43946"; 
        awayTeam = "43938"; 
    }

    function setFinalistTeams(string _homeTeam, string _awayTeam) public onlyOwner onlyBeforeMatch {
        require(!finalistTeamFIFAIdsSet);
        homeTeam = _homeTeam;
        awayTeam = _awayTeam;
        finalistTeamFIFAIdsSet = true;
    }

    function bet(bool _team) public payable onlyBeforeMatch {
      require(msg.value > 0);

      if(_team) {
        totalPotHomeTeam = totalPotHomeTeam.add(msg.value);
        bets[msg.sender].betValueHomeTeam = bets[msg.sender].betValueHomeTeam.add(msg.value);
      } else {
        totalPotAwayTeam = totalPotAwayTeam.add(msg.value);
        bets[msg.sender].betValueAwayTeam = bets[msg.sender].betValueAwayTeam.add(msg.value);
      }

      emit successfulBet(msg.sender, _team, msg.value);
    }

    function setWinningTeam() public payable onlyAfterMatch {
      require(!winningTeamSet);
      if (oraclize_getPrice("URL") > this.balance) {
        LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "json(https://api.fifa.com/api/v1/calendar/matches?idCompetition=17&idSeason=254645&language=en&count=500).Results.63.Winner");
      }
    }

    function __callback(bytes32 myid, string result) {
      if (msg.sender != oraclize_cbAddress()) revert();
      require(sha3(result) == sha3(homeTeam) || sha3(result) == sha3(awayTeam));
      if(sha3(result) == sha3(homeTeam)) {
        winningTeam = true;
      } else {
        winningTeam = false;
      }
      winningTeamSet = true;
    }

    function withdrawWinnings() public onlyAfterMatch  {
      require(winningTeamSet);
      uint256 yourBet;
      uint256 reward;
      if(winningTeam) {
        yourBet = bets[msg.sender].betValueHomeTeam;
        reward = totalPotAwayTeam.mul(yourBet).div(totalPotHomeTeam).mul(97).div(100);
        bets[msg.sender].betValueHomeTeam = 0;
        msg.sender.transfer(yourBet.add(reward));
      } else {
        yourBet = bets[msg.sender].betValueAwayTeam;
        reward = totalPotHomeTeam.mul(yourBet).div(totalPotAwayTeam).mul(97).div(100);
        bets[msg.sender].betValueAwayTeam = 0;
        msg.sender.transfer(yourBet.add(reward));
      }
    }

    function closeHouse() public onlyAfterWithdrawPeriod {
      selfdestruct(owner);
    }

    


    modifier onlyBeforeMatch() {
      require(block.timestamp < 1531666800, "you can not bet once the match started");
      _;
    }

    


    modifier onlyAfterMatch() {
      require(block.timestamp > 1531681200, "you can not set the winning team before the end of the match");
      _;
    }

    


    modifier onlyAfterWithdrawPeriod() {
      require(block.timestamp > 1534359600,"you can not close the house before the end of the withdrawal period");
      _;
    }

}