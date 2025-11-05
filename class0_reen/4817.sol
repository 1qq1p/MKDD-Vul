pragma solidity ^0.4.21;

library BWUtility {
    
    


    
    function ceil(uint _amount, uint _multiple) pure public returns (uint) {
        return ((_amount + _multiple - 1) / _multiple) * _multiple;
    }

    
    
    
    
    
    
    function isAdjacent(uint8 _x1, uint8 _y1, uint8 _x2, uint8 _y2) pure public returns (bool) {
        return ((_x1 == _x2 &&      (_y2 - _y1 == 1 || _y1 - _y2 == 1))) ||      
               ((_y1 == _y2 &&      (_x2 - _x1 == 1 || _x1 - _x2 == 1))) ||      
               ((_x2 - _x1 == 1 &&  (_y2 - _y1 == 1 || _y1 - _y2 == 1))) ||      
               ((_x1 - _x2 == 1 &&  (_y2 - _y1 == 1 || _y1 - _y2 == 1)));        
    }

    
    function toTileId(uint8 _x, uint8 _y) pure public returns (uint16) {
        return uint16(_x) << 8 | uint16(_y);
    }

    
    function fromTileId(uint16 _tileId) pure public returns (uint8, uint8) {
        uint8 y = uint8(_tileId);
        uint8 x = uint8(_tileId >> 8);
        return (x, y);
    }
    
    function getBoostFromTile(address _claimer, address _attacker, address _defender, uint _blockValue) pure public returns (uint, uint) {
        if (_claimer == _attacker) {
            return (_blockValue, 0);
        } else if (_claimer == _defender) {
            return (0, _blockValue);
        }
    }
}






interface ERC20I {
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function balanceOf(address _holder) external view returns (uint256);
}


contract BWService {
    using SafeMath for uint256;
    address private owner;
    address private bw;
    address private bwMarket;
    BWData private bwData;
    uint private seed = 42;
    uint private WITHDRAW_FEE = 5; 
    uint private ATTACK_FEE = 5; 
    uint private ATTACK_BOOST_CAP = 300; 
    uint private DEFEND_BOOST_CAP = 300; 
    uint private ATTACK_BOOST_MULTIPLIER = 100; 
    uint private DEFEND_BOOST_MULTIPLIER = 100; 
    mapping (uint16 => address) private localGames;
    
    modifier isOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }  

    modifier isValidCaller {
        if (msg.sender != bw && msg.sender != bwMarket) {
            revert();
        }
        _;
    }

    event TileClaimed(uint16 tileId, address newClaimer, uint priceInWei, uint creationTime);
    event TileFortified(uint16 tileId, address claimer, uint addedValueInWei, uint priceInWei, uint fortifyTime); 
    event TileAttackedSuccessfully(uint16 tileId, address attacker, uint attackAmount, uint totalAttackAmount, address defender, uint defendAmount, uint totalDefendAmount, uint attackRoll, uint attackTime); 
    event TileDefendedSuccessfully(uint16 tileId, address attacker, uint attackAmount, uint totalAttackAmount, address defender, uint defendAmount, uint totalDefendAmount, uint attackRoll, uint defendTime); 
    event BlockValueMoved(uint16 sourceTileId, uint16 destTileId, address owner, uint movedBlockValue, uint postSourceValue, uint postDestValue, uint moveTime); 
    event UserBattleValueUpdated(address userAddress, uint battleValue, bool isWithdraw);

    
    constructor(address _bwData) public {
        bwData = BWData(_bwData);
        owner = msg.sender;
    }

    
    function () payable public {
        revert();
    }

    
    function kill() public isOwner {
        selfdestruct(owner);
    }

    function setValidBwCaller(address _bw) public isOwner {
        bw = _bw;
    }
    
    function setValidBwMarketCaller(address _bwMarket) public isOwner {
        bwMarket = _bwMarket;
    }

    function setWithdrawFee(uint _feePercentage) public isOwner {
        WITHDRAW_FEE = _feePercentage;
    }

    function setAttackFee(uint _feePercentage) public isOwner {
        ATTACK_FEE = _feePercentage;
    }

    function setAttackBoostMultipler(uint _multiplierPercentage) public isOwner {
        ATTACK_BOOST_MULTIPLIER = _multiplierPercentage;
    }

    function setDefendBoostMultiplier(uint _multiplierPercentage) public isOwner {
        DEFEND_BOOST_MULTIPLIER = _multiplierPercentage;
    }

    function setAttackBoostCap(uint _capPercentage) public isOwner {
        ATTACK_BOOST_CAP = _capPercentage;
    }

    function setDefendBoostCap(uint _capPercentage) public isOwner {
        DEFEND_BOOST_CAP = _capPercentage;
    }

    
    
    
    
    function storeInitialClaim(address _msgSender, uint16[] _claimedTileIds, uint _claimAmount, bool _useBattleValue) public isValidCaller {
        uint tileCount = _claimedTileIds.length;
        require(tileCount > 0);
        require(_claimAmount >= 1 finney * tileCount); 
        require(_claimAmount % tileCount == 0); 

        uint valuePerBlockInWei = _claimAmount.div(tileCount); 
        require(valuePerBlockInWei >= 5 finney);

        if (_useBattleValue) {
            subUserBattleValue(_msgSender, _claimAmount, false);  
        }

        addGlobalBlockValueBalance(_claimAmount);

        uint16 tileId;
        bool isNewTile;
        for (uint16 i = 0; i < tileCount; i++) {
            tileId = _claimedTileIds[i];
            isNewTile = bwData.isNewTile(tileId); 
            require(isNewTile); 

            
            emit TileClaimed(tileId, _msgSender, valuePerBlockInWei, block.timestamp);

            
            bwData.storeClaim(tileId, _msgSender, valuePerBlockInWei);
        }
    }

    function fortifyClaims(address _msgSender, uint16[] _claimedTileIds, uint _fortifyAmount, bool _useBattleValue) public isValidCaller {
        uint tileCount = _claimedTileIds.length;
        require(tileCount > 0);

        address(this).balance.add(_fortifyAmount); 
        require(_fortifyAmount % tileCount == 0); 
        uint addedValuePerTileInWei = _fortifyAmount.div(tileCount); 
        require(_fortifyAmount >= 1 finney * tileCount); 

        address claimer;
        uint blockValue;
        for (uint16 i = 0; i < tileCount; i++) {
            (claimer, blockValue) = bwData.getTileClaimerAndBlockValue(_claimedTileIds[i]);
            require(claimer != 0); 
            require(claimer == _msgSender); 

            if (_useBattleValue) {
                subUserBattleValue(_msgSender, addedValuePerTileInWei, false);
            }
            
            fortifyClaim(_msgSender, _claimedTileIds[i], addedValuePerTileInWei);
        }
    }

    function fortifyClaim(address _msgSender, uint16 _claimedTileId, uint _fortifyAmount) private {
        uint blockValue;
        uint sellPrice;
        (blockValue, sellPrice) = bwData.getCurrentBlockValueAndSellPriceForTile(_claimedTileId);
        uint updatedBlockValue = blockValue.add(_fortifyAmount);
        
        emit TileFortified(_claimedTileId, _msgSender, _fortifyAmount, updatedBlockValue, block.timestamp);
        
        
        bwData.updateTileBlockValue(_claimedTileId, updatedBlockValue);

        
        addGlobalBlockValueBalance(_fortifyAmount);
    }

    
    
    
    
    
    function random(uint _upper) private returns (uint)  {
        seed = uint(keccak256(blockhash(block.number - 1), block.coinbase, block.timestamp, seed, address(0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE).balance));
        return seed % _upper;
    }

    
    
    function attackTile(address _msgSender, uint16 _tileId, uint _attackAmount, bool _useBattleValue) public isValidCaller {
        require(_attackAmount >= 1 finney);         
        require(_attackAmount % 1 finney == 0);

        address claimer;
        uint blockValue;
        (claimer, blockValue) = bwData.getTileClaimerAndBlockValue(_tileId);
        
        require(claimer != 0); 
        require(claimer != _msgSender); 
        require(claimer != owner); 

        
        
        
        uint attackBoost;
        uint defendBoost;
        (attackBoost, defendBoost) = bwData.calculateBattleBoost(_tileId, _msgSender, claimer);

        
        attackBoost = attackBoost.mul(ATTACK_BOOST_MULTIPLIER).div(100);
        defendBoost = defendBoost.mul(DEFEND_BOOST_MULTIPLIER).div(100);
        
        
        if (attackBoost > _attackAmount.mul(ATTACK_BOOST_CAP).div(100)) {
            attackBoost = _attackAmount.mul(ATTACK_BOOST_CAP).div(100);
        }
        if (defendBoost > blockValue.mul(DEFEND_BOOST_CAP).div(100)) {
            defendBoost = blockValue.mul(DEFEND_BOOST_CAP).div(100);
        }

        uint totalAttackAmount = _attackAmount.add(attackBoost);
        uint totalDefendAmount = blockValue.add(defendBoost);

        
        require(totalAttackAmount.div(10) <= totalDefendAmount); 
        require(totalAttackAmount >= totalDefendAmount.div(10)); 

        uint attackFeeAmount = _attackAmount.mul(ATTACK_FEE).div(100);
        uint attackAmountAfterFee = _attackAmount.sub(attackFeeAmount);
        
        updateFeeBalance(attackFeeAmount);

        
        uint attackRoll = random(totalAttackAmount.add(totalDefendAmount)); 

        
        if (attackRoll > totalDefendAmount) {
            
            bwData.setClaimerForTile(_tileId, _msgSender);

            
            if (_useBattleValue) {
                
                addUserBattleValue(_msgSender, attackAmountAfterFee); 
                subUserBattleValue(_msgSender, attackAmountAfterFee, false);
            } else {
                addUserBattleValue(_msgSender, attackAmountAfterFee); 
            }
            addUserBattleValue(claimer, 0);

            bwData.updateTileTimeStamp(_tileId);
            
            emit TileAttackedSuccessfully(_tileId, _msgSender, attackAmountAfterFee, totalAttackAmount, claimer, blockValue, totalDefendAmount, attackRoll, block.timestamp);
        } else {
            bwData.setClaimerForTile(_tileId, claimer); 
            
            if (_useBattleValue) {
                subUserBattleValue(_msgSender, attackAmountAfterFee, false); 
            }
            addUserBattleValue(claimer, attackAmountAfterFee); 
            
            
            emit TileDefendedSuccessfully(_tileId, _msgSender, attackAmountAfterFee, totalAttackAmount, claimer, blockValue, totalDefendAmount, attackRoll, block.timestamp);
        }
    }

    function updateFeeBalance(uint attackFeeAmount) private {
        uint feeBalance = bwData.getFeeBalance();
        feeBalance = feeBalance.add(attackFeeAmount);
        bwData.setFeeBalance(feeBalance);
    }

    function moveBlockValue(address _msgSender, uint8 _xSource, uint8 _ySource, uint8 _xDest, uint8 _yDest, uint _moveAmount) public isValidCaller {
        uint16 sourceTileId = BWUtility.toTileId(_xSource, _ySource);
        uint16 destTileId = BWUtility.toTileId(_xDest, _yDest);

        address sourceTileClaimer;
        address destTileClaimer;
        uint sourceTileBlockValue;
        uint destTileBlockValue;
        (sourceTileClaimer, sourceTileBlockValue) = bwData.getTileClaimerAndBlockValue(sourceTileId);
        (destTileClaimer, destTileBlockValue) = bwData.getTileClaimerAndBlockValue(destTileId);

        uint newBlockValue = sourceTileBlockValue.sub(_moveAmount);
        
        require(newBlockValue == 0 || newBlockValue >= 5 finney);

        require(sourceTileClaimer == _msgSender);
        require(destTileClaimer == _msgSender);
        require(_moveAmount >= 1 finney); 
        require(_moveAmount % 1 finney == 0); 
        
        
        require(BWUtility.isAdjacent(_xSource, _ySource, _xDest, _yDest));

        sourceTileBlockValue = sourceTileBlockValue.sub(_moveAmount);
        destTileBlockValue = destTileBlockValue.add(_moveAmount);

        
        if (sourceTileBlockValue == 0) {
            bwData.deleteTile(sourceTileId);
        } else {
            bwData.updateTileBlockValue(sourceTileId, sourceTileBlockValue);
            bwData.deleteOffer(sourceTileId); 
        }

        bwData.updateTileBlockValue(destTileId, destTileBlockValue);
        bwData.deleteOffer(destTileId);   
        emit BlockValueMoved(sourceTileId, destTileId, _msgSender, _moveAmount, sourceTileBlockValue, destTileBlockValue, block.timestamp);        
    }

    function verifyAmount(address _msgSender, uint _msgValue, uint _amount, bool _useBattleValue) view public isValidCaller {
        if (_useBattleValue) {
            require(_msgValue == 0);
            require(bwData.getUserBattleValue(_msgSender) >= _amount);
        } else {
            require(_amount == _msgValue);
        }
    }

    function setLocalGame(uint16 _tileId, address localGameAddress) public isOwner {
        localGames[_tileId] = localGameAddress;
    }

    function getLocalGame(uint16 _tileId) view public isValidCaller returns (address) {
        return localGames[_tileId];
    }

    
    function withdrawBattleValue(address msgSender, uint _battleValueInWei) public isValidCaller returns (uint) {
        
        uint fee = _battleValueInWei.mul(WITHDRAW_FEE).div(100); 
        uint amountToWithdraw = _battleValueInWei.sub(fee);
        uint feeBalance = bwData.getFeeBalance();
        feeBalance = feeBalance.add(fee);
        bwData.setFeeBalance(feeBalance);
        subUserBattleValue(msgSender, _battleValueInWei, true);
        return amountToWithdraw;
    }

    function addUserBattleValue(address _userId, uint _amount) public isValidCaller {
        uint userBattleValue = bwData.getUserBattleValue(_userId);
        uint newBattleValue = userBattleValue.add(_amount);
        bwData.setUserBattleValue(_userId, newBattleValue); 
        emit UserBattleValueUpdated(_userId, newBattleValue, false);
    }
    
    function subUserBattleValue(address _userId, uint _amount, bool _isWithdraw) public isValidCaller {
        uint userBattleValue = bwData.getUserBattleValue(_userId);
        require(_amount <= userBattleValue); 
        uint newBattleValue = userBattleValue.sub(_amount);
        bwData.setUserBattleValue(_userId, newBattleValue); 
        emit UserBattleValueUpdated(_userId, newBattleValue, _isWithdraw);
    }

    function addGlobalBlockValueBalance(uint _amount) public isValidCaller {
        
        uint blockValueBalance = bwData.getBlockValueBalance();
        bwData.setBlockValueBalance(blockValueBalance.add(_amount));
    }

    function subGlobalBlockValueBalance(uint _amount) public isValidCaller {
        
        uint blockValueBalance = bwData.getBlockValueBalance();
        bwData.setBlockValueBalance(blockValueBalance.sub(_amount));
    }

    
    function transferTokens(address _tokenAddress, address _recipient) public isOwner {
        ERC20I token = ERC20I(_tokenAddress);
        require(token.transfer(_recipient, token.balanceOf(this)));
    }
}




