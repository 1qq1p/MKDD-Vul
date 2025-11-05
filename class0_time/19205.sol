pragma solidity ^0.5.0;

contract HalfRouletteConstant {
    
    
    
    
    
    
    
    uint constant BET_EXPIRATION_BLOCKS = 250;

    uint constant HOUSE_EDGE_PERCENT = 1; 
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0004 ether; 

    uint constant RANK_FUNDS_PERCENT = 7; 
    uint constant INVITER_BENEFIT_PERCENT = 7; 

    uint constant MIN_BET = 0.01 ether; 
    uint constant MAX_BET = 300000 ether; 
    uint constant MIN_JACKPOT_BET = 0.1 ether;
    uint constant JACKPOT_FEE = 0.001 ether;

    uint constant BASE_WIN_RATE = 100000;
}
