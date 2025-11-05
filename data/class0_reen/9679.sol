pragma solidity ^0.4.23;










contract IBCLotteryEvents {
    
    
    event onEndTx
    (
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount,
        uint256 potAmount
    );
    
	
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    
    event onWithdrawAndDistribute
    (
        address playerAddress,
        uint256 ethOut,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    
    event onBuyAndDistribute
    (
        address playerAddress,
        uint256 ethIn,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    event onBuyTicketAndDistribute
    (
        address playerAddress,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    
    event onReLoadAndDistribute
    (
        address playerAddress,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    
    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );
    
    event onRefundTicket
    (
        uint256 indexed playerID,
        uint256 refundAmount
    );
}








