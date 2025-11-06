





























pragma solidity ^0.4.11;

contract EtherFlipGold is usingOraclize {
    
    modifier ownerAction {
         if (msg.sender != owner) throw;
         _;
    }
    
    modifier oraclizeAction {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }
    
    
    event newRandomValue(uint roll, address player, uint amount, uint gameType); 
    event proofFailed(address player, uint amount, uint gameType); 
    
    
    token public tokenReward;
    token public bonusToken;
    token public sponsoredBonusToken;

    
    address public owner;
    
    
    uint public generatedBytes;
    uint public multiplier = 500;
    uint public maxBet = (20000000000000000 * 1 wei);
    uint public minBet = (10000000000000000 * 1 wei);
    uint public rewardAmount = 1;
    uint public bonusAmount;
    uint public sponsoredBonusAmount;
    uint public callbackGas = 250000;
    
    
    uint public baseComparable = 65527;
    uint public bonusMin;
    uint public bonusMax;
    uint public sponsoredBonusMin;
    uint public sponsoredBonusMax;

    
    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => uint) playerAmount;

    function EtherFlipGold() {
        owner = msg.sender;
        oraclize_setProof(proofType_Ledger);
    }
    
    function () payable {
        if (msg.sender != owner) {
            if (msg.value > maxBet || msg.value < minBet) throw;
        
            oraclize_setProof(proofType_Ledger);
            uint numberOfBytes = 2;
            uint delay = 0;
            bytes32 queryId = oraclize_newRandomDSQuery(delay, numberOfBytes, callbackGas); 
            playerAddress[queryId] = msg.sender;
            playerAmount[queryId] = msg.value;
        }
    }
    
    function __callback(bytes32 _queryId, string _result, bytes _proof) oraclizeAction { 
        uint amount = playerAmount[_queryId];
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0 || _proof.length == 0) {
            
            proofFailed(playerAddress[_queryId], amount, 1);
            playerAddress[_queryId].transfer(amount);
            delete playerAddress[_queryId];
            delete playerAmount[_queryId];
        } else {
            generatedBytes = uint(sha3(_result)) % 2**(2 *8);
            newRandomValue(generatedBytes, playerAddress[_queryId], amount, 1);

            if (generatedBytes > baseComparable) {
                playerAddress[_queryId].transfer(amount * multiplier);
            } 
            
            if (generatedBytes <= baseComparable && rewardAmount > 0) {
                tokenReward.transfer(playerAddress[_queryId], rewardAmount);
            } 
        
            if (generatedBytes >= bonusMin && generatedBytes <= bonusMax && bonusAmount > 0) {
                bonusToken.transfer(playerAddress[_queryId], bonusAmount);
            }
        
            if (generatedBytes >= sponsoredBonusMin && generatedBytes <= sponsoredBonusMax && sponsoredBonusAmount > 0) {
                sponsoredBonusToken.transfer(playerAddress[_queryId], sponsoredBonusAmount);
            }
        
            delete playerAddress[_queryId];
            delete playerAmount[_queryId];
        }
    }
    
    function updateMaxMinComparables(uint updatedMaxBet, uint updatedMinBet, uint updatedBaseComparable) ownerAction {
        maxBet = updatedMaxBet * 1 wei;
        minBet = updatedMinBet * 1 wei;
        baseComparable = updatedBaseComparable;
    }  
    
    function updateOwner(address updatedOwner) ownerAction {
        owner = updatedOwner;
    }
    
    function updateRewardToken(address updatedToken, uint updatedRewardAmount) ownerAction {
        tokenReward = token(updatedToken);
        rewardAmount = updatedRewardAmount;
    }
    
    function refundTransfer(address outboundAddress, uint amount) ownerAction {        
        outboundAddress.transfer(amount);
    }
    
    function walletSend(address tokenAddress, uint amount, address outboundAddress) ownerAction {
        token chosenToken = token(tokenAddress);
        chosenToken.transfer(outboundAddress, amount);
    }
    
    function updateGameSpecifics(uint newGas, uint newMultiplier) ownerAction {
        callbackGas = newGas;
        multiplier = newMultiplier;
    }
    
    function setBonusToken(address newBonusToken, uint newBonusAmount, uint newBonusMin, uint newBonusMax, address newSponsoredBonusToken, uint newSponsoredBonusAmount, uint newSBonusMin, uint newSBonusMax) ownerAction {
        bonusToken = token(newBonusToken);
        bonusAmount = newBonusAmount;
        bonusMin = newBonusMin;
        bonusMax = newBonusMax;
        
        sponsoredBonusToken = token(newSponsoredBonusToken);
        sponsoredBonusAmount = newSponsoredBonusAmount;
        sponsoredBonusMin = newSBonusMin;
        sponsoredBonusMax = newSBonusMax;
    }
}