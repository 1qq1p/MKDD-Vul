pragma solidity ^0.4.23;


contract Etherman is Administrable{

    struct game{
        uint32 timestamp;
        uint128 stake;
        address player1;
        address player2;
    }

    struct player{
        uint8 team;
        uint64 score;
        address referrer;
    }

    mapping (bytes12 => game) public games;
    mapping (address => player) public players;

    event NewGame(bytes32 gameId, address player1, uint stake);
    event GameStarted(bytes32 gameId, address player1, address player2, uint stake);
    event GameDestroyed(bytes32 gameId);
    event GameEnd(bytes32 gameId, address winner, uint value);
    event NewHighscore(address holder, uint score, uint lastPot);

    modifier onlyHuman(){
        require(msg.sender == tx.origin, "contract calling");
        _;
    }

    constructor(address signingAddress, uint min, uint max) public{
        setSigner(signingAddress);
        minStake = min;
        maxStake = max;
    }

    


    function initGameReferred(bytes12 gameId, address referrer, uint8 team) public payable active onlyHuman validAddress(referrer){
        
        if(players[msg.sender].referrer == 0x0 && players[msg.sender].score == 0)
            players[msg.sender] = player(team, 0, referrer);
        initGame(gameId);
    }

    


    function initGameTeam(bytes12 gameId, uint8 team) public payable active onlyHuman {
        if(players[msg.sender].score == 0)
            players[msg.sender].team = team;
        initGame(gameId);
    }

    


    function initGame(bytes12 gameId) public payable active onlyHuman {
        game storage cGame = games[gameId];
        if(cGame.player1==0x0) _initGame(gameId);
        else _joinGame(gameId);
    }

    function _initGame(bytes12 gameId) internal {
        require(msg.value <= maxStake, "stake needs to be lower than or equal to the max stake");
        require(msg.value >= minStake, "stake needs to be at least the min stake");
        require(games[gameId].stake == 0, "game with the given id already exists");
        games[gameId] = game(uint32(now), uint128(msg.value), msg.sender, 0x0);
        emit NewGame(gameId, msg.sender, msg.value);
    }

    


    function joinGameReferred(bytes12 gameId, address referrer, uint8 team) public payable active onlyHuman validAddress(referrer){
        
        if(players[msg.sender].referrer == 0x0 && players[msg.sender].score == 0)
            players[msg.sender] = player(team, 0, referrer);
        joinGame(gameId);
    }

    


    function joinGameTeam(bytes12 gameId, uint8 team) public payable active onlyHuman{
        if(players[msg.sender].score == 0)
            players[msg.sender].team = team;
        joinGame(gameId);
    }

    


    function joinGame(bytes12 gameId) public payable active onlyHuman{
        game storage cGame = games[gameId];
        if(cGame.player1==0x0) _initGame(gameId);
        else _joinGame(gameId);

    }

    function _joinGame(bytes12 gameId) internal {
        game storage cGame = games[gameId];
        require(cGame.player1 != msg.sender, "cannot play with one self");
        require(msg.value >= cGame.stake, "value does not suffice to join the game");
        cGame.player2 = msg.sender;
        cGame.timestamp = uint32(now);
        emit GameStarted(gameId, cGame.player1, msg.sender, cGame.stake);
        if(msg.value > cGame.stake) developerPot += msg.value - cGame.stake;
    }

    



    function withdraw(bytes12 gameId) public onlyHuman{
        game storage cGame = games[gameId];
        uint128 value = cGame.stake;
        if(msg.sender == cGame.player1){
            if(cGame.player2 == 0x0){
                delete games[gameId];
                msg.sender.transfer(value);
            }
            else if(cGame.timestamp + minimumWait <= now){
                address player2 = cGame.player2;
                delete games[gameId];
                msg.sender.transfer(value);
                player2.transfer(value);
            }
            else{
                revert("minimum waiting time has not yet passed");
            }
        }
        else if(msg.sender == cGame.player2){
            if(cGame.timestamp + minimumWait <= now){
                address player1 = cGame.player1;
                delete games[gameId];
                msg.sender.transfer(value);
                player1.transfer(value);
            }
            else{
                revert("minimum waiting time has not yet passed");
            }
        }
        else{
            revert("sender is not a player in this game");
        }
        emit GameDestroyed(gameId);
    }

    



    function claimWin(bytes12 gameId, uint8 v, bytes32 r, bytes32 s) public onlyHuman{
        game storage cGame = games[gameId];
        require(cGame.player2!=0x0, "game has not started yet");
        require(msg.sender == cGame.player1 || msg.sender == cGame.player2, "sender is not a player in this game");
        require(ecrecover(keccak256(abi.encodePacked(gameId, msg.sender)), v, r, s) == signer, "invalid signature");
        uint256 value = 2*cGame.stake;
        uint256 win = winnerPercent * value / 1000;
        addScore(msg.sender, cGame.stake);
        delete games[gameId];
        charityPot += value * charityPercent / 1000;
        
        if(players[highscoreHolder].team == players[msg.sender].team){
            win += value * highscorePercent / 1000;
        }
        else{
            highscorePot += value * highscorePercent / 1000;
        }
        surprisePot += value * surprisePercent / 1000;
        if(players[msg.sender].referrer == 0x0){
            developerPot += value * (developerPercent + affiliatePercent) / 1000;
        }
        else{
            developerPot += value * developerPercent / 1000;
            affiliateBalance[players[msg.sender].referrer] += value * affiliatePercent / 1000;
        }
        msg.sender.transfer(win);
        emit GameEnd(gameId, msg.sender, win);
    }

    




    function addScore(address receiver, uint stake) private{
        player storage rec = players[receiver];
        player storage hsh = players[highscoreHolder];
        uint64 x = uint64(stake/(10 finney));
        uint64 score = (61 * x + 100) / ( x + 100); 
        if(rec.team != hsh.team){
            uint64 extra = score * 25 / 100;
            if (extra == 0) extra = 1;
            score += extra;
        }
        rec.score += score;
        if(rec.score > hsh.score){
            uint pot = highscorePot;
            if(pot > 0){
                highscorePot = 0;
                highscoreHolder.transfer(pot);
            }
            highscoreHolder = receiver;
            emit NewHighscore(receiver, rec.score, pot);
        }
    }

    


    function() public payable{
        developerPot+=msg.value;
    }

    


     function setScore(address user, uint64 score, uint8 team) public onlyOwner{
          players[user].score = score;
          players[user].team = team;
      }

}