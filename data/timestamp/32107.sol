pragma solidity ^0.4.11;


contract WolkExchange is WolkProtocol, BancorFormula {

    uint256 public maxPerExchangeBP = 50;

    
    
    
    function setMaxPerExchange(uint256 _maxPerExchange) onlyOwner returns (bool success) {
        require( (_maxPerExchange >= 10) && (_maxPerExchange <= 100) );
        maxPerExchangeBP = _maxPerExchange;
        return true;
    }

    
    
    function EstLiquidationCap() public constant returns (uint256) {
        if (saleCompleted){
            var liquidationMax  = safeDiv(safeMul(totalTokens, maxPerExchangeBP), 10000);
            if (liquidationMax < 100 * 10**decimals){ 
                liquidationMax = 100 * 10**decimals;
            }
            return liquidationMax;   
        }else{
            return 0;
        }
    }

    
    
    
    function sellWolk(uint256 _wolkAmount) isTransferable() external returns(uint256) {
        uint256 sellCap = EstLiquidationCap();
        uint256 ethReceivable = calculateSaleReturn(totalTokens, reserveBalance, percentageETHReserve, _wolkAmount);
        require( (sellCap >= _wolkAmount) && (balances[msg.sender] >= _wolkAmount) && (this.balance > ethReceivable) );
        balances[msg.sender] = safeSub(balances[msg.sender], _wolkAmount);
        totalTokens = safeSub(totalTokens, _wolkAmount);
        reserveBalance = safeSub(this.balance, ethReceivable);
        WolkDestroyed(msg.sender, _wolkAmount);
        msg.sender.transfer(ethReceivable);
        return ethReceivable;     
    }

    
    
    function purchaseWolk() isTransferable() payable external returns(uint256){
        uint256 wolkReceivable = calculatePurchaseReturn(totalTokens, reserveBalance, percentageETHReserve, msg.value);
        totalTokens = safeAdd(totalTokens, wolkReceivable);
        balances[msg.sender] = safeAdd(balances[msg.sender], wolkReceivable);
        reserveBalance = safeAdd(reserveBalance, msg.value);
        WolkCreated(msg.sender, wolkReceivable);
        return wolkReceivable;
    }

    
    
    
    
    function purchaseExactWolk(uint256 _exactWolk) isTransferable() payable external returns(uint256){
        uint256 wolkReceivable = calculatePurchaseReturn(totalTokens, reserveBalance, percentageETHReserve, msg.value);
        if (wolkReceivable < _exactWolk){
            
            revert();
            return msg.value;
        }else {
            var wolkDiff = safeSub(wolkReceivable, _exactWolk);
            uint256 ethRefundable = 0;
            
            if (wolkDiff < 10**decimals){
                
                totalTokens = safeAdd(totalTokens, wolkReceivable);
                balances[msg.sender] = safeAdd(balances[msg.sender], wolkReceivable);
                reserveBalance = safeAdd(reserveBalance, msg.value);
                WolkCreated(msg.sender, wolkReceivable);
                return 0;     
            }else{
                ethRefundable = calculateSaleReturn( safeAdd(totalTokens, wolkReceivable) , safeAdd(reserveBalance, msg.value), percentageETHReserve, wolkDiff);
                totalTokens = safeAdd(totalTokens, _exactWolk);
                balances[msg.sender] = safeAdd(balances[msg.sender], _exactWolk);
                reserveBalance = safeAdd(reserveBalance, safeSub(msg.value, ethRefundable));
                WolkCreated(msg.sender, _exactWolk);
                msg.sender.transfer(ethRefundable);
                return ethRefundable;
            }
        }
    }
}