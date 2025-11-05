pragma solidity ^0.4.24;


contract Coinevents {
    
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );
    event onBuy (
        address playerAddress,
        uint256 begin,
        uint256 end,
        uint256 round,
        bytes32 playerName
    );
    
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    event onSettle(
        uint256 rid,
        uint256 ticketsout,
        address winner,
        uint256 luckynum,
        uint256 jackpot
    );
    
    event onActivate(
        uint256 rid
    );
}

