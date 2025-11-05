pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





contract UniswapHandler is ExchangeHandler, AllowanceSetter {
    



    struct OrderData {
        address exchangeAddress;
        uint256 amountToGive;
    }

    
    
    
    
    constructor(
        address _selectorProvider,
        address _totlePrimary,
        address errorReporter

    ) ExchangeHandler(_selectorProvider, _totlePrimary, errorReporter) public {

    }

    



    
    
    
    function getAmountToGive(
        OrderData data
    )
        public
        view
        whenNotPaused
        onlySelf
        returns (uint256 amountToGive)
    {
        amountToGive = data.amountToGive;
    }

    
    
    
    
    function staticExchangeChecks(
        OrderData data
    )
        public
        view
        whenNotPaused
        onlySelf
        returns (bool checksPassed)
    {
        return true;
    }

    
    
    
    
    
    function performBuyOrder(
        OrderData data,
        uint256 amountToGiveForOrder
    )
        public
        payable
        whenNotPaused
        onlySelf
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        UniswapExchange ex = UniswapExchange(data.exchangeAddress);
        amountSpentOnOrder = amountToGiveForOrder;
        amountReceivedFromOrder = ex.ethToTokenTransferInput.value(amountToGiveForOrder)(1, block.timestamp+1, totlePrimary);
        

    }

    
    
    
    
    
    function performSellOrder(
        OrderData data,
        uint256 amountToGiveForOrder
    )
        public
        whenNotPaused
        onlySelf
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        UniswapExchange ex = UniswapExchange(data.exchangeAddress);
        approveAddress(data.exchangeAddress, ex.tokenAddress());
        amountSpentOnOrder = amountToGiveForOrder;
        amountReceivedFromOrder = ex.tokenToEthTransferInput(amountToGiveForOrder, 1, block.timestamp+1, totlePrimary);
        
    }

    
    
    function() public payable {
        
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        require(size > 0);
    }
}