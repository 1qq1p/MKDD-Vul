pragma solidity 0.4.18;




interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}






contract KyberPayWrapper is Withdrawable, ReentrancyGuard {
    ERC20 constant public ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    struct PayData {
        ERC20 src;
        uint srcAmount;
        ERC20 dest;
        address destAddress;
        uint maxDestAmount;
        uint minConversionRate;
        address walletId;
        bytes paymentData;
        bytes hint;
        KyberNetwork kyberNetworkProxy;
    }

    function () public payable {} 

    event ProofOfPayment(address indexed _payer, address indexed _payee, address _token, uint _amount, bytes _data);

    function pay(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes paymentData,
        bytes hint,
        KyberNetwork kyberNetworkProxy
    ) public nonReentrant payable
    {

        require(src != address(0));
        require(dest != address(0));
        require(destAddress != address(0));

        if (src == ETH_TOKEN_ADDRESS) require(srcAmount == msg.value);

        PayData memory payData = PayData({
            src:src,
            srcAmount:srcAmount,
            dest:dest,
            destAddress:destAddress,
            maxDestAmount:maxDestAmount,
            minConversionRate:minConversionRate,
            walletId:walletId,
            paymentData:paymentData,
            hint:hint,
            kyberNetworkProxy:kyberNetworkProxy
        });

        uint paidAmount = (src == dest) ? doPayWithoutKyber(payData) : doPayWithKyber(payData);

        
        ProofOfPayment(msg.sender ,destAddress, dest, paidAmount, paymentData);
    }

    function doPayWithoutKyber(PayData memory payData) internal returns (uint paidAmount) {

        uint returnAmount;

        if (payData.srcAmount > payData.maxDestAmount) {
            paidAmount = payData.maxDestAmount;
            returnAmount = payData.srcAmount - payData.maxDestAmount;
        } else {
            paidAmount = payData.srcAmount;
            returnAmount = 0;
        }

        if (payData.src == ETH_TOKEN_ADDRESS) {
            payData.destAddress.transfer(paidAmount);

            
            if (returnAmount > 0) msg.sender.transfer(returnAmount);
        } else {
            require(payData.src.transferFrom(msg.sender, payData.destAddress, paidAmount));
        }
    }

    function doPayWithKyber(PayData memory payData) internal returns (uint paidAmount) {

        uint returnAmount;
        uint wrapperSrcBalanceBefore;
        uint destAddressBalanceBefore;
        uint wrapperSrcBalanceAfter;
        uint destAddressBalanceAfter;
        uint srcAmountUsed;

        if (payData.src != ETH_TOKEN_ADDRESS) {
            require(payData.src.transferFrom(msg.sender, address(this), payData.srcAmount));
            require(payData.src.approve(payData.kyberNetworkProxy, 0));
            require(payData.src.approve(payData.kyberNetworkProxy, payData.srcAmount));
        }

        (wrapperSrcBalanceBefore, destAddressBalanceBefore) = getBalances(
            payData.src,
            payData.dest,
            payData.destAddress
        );

        paidAmount = doTradeWithHint(payData);
        if (payData.src != ETH_TOKEN_ADDRESS) require(payData.src.approve(payData.kyberNetworkProxy, 0));

        (wrapperSrcBalanceAfter, destAddressBalanceAfter) = getBalances(payData.src, payData.dest, payData.destAddress);

        
        require(destAddressBalanceAfter > destAddressBalanceBefore);
        require(paidAmount == (destAddressBalanceAfter - destAddressBalanceBefore));

        
        require(wrapperSrcBalanceBefore >= wrapperSrcBalanceAfter);
        srcAmountUsed = wrapperSrcBalanceBefore - wrapperSrcBalanceAfter;

        require(payData.srcAmount >= srcAmountUsed);
        returnAmount = payData.srcAmount - srcAmountUsed;

        
        if (returnAmount > 0) {
            if (payData.src == ETH_TOKEN_ADDRESS) {
                msg.sender.transfer(returnAmount);
            } else {
                require(payData.src.transfer(msg.sender, returnAmount));
            }
        }
    }

    function doTradeWithHint(PayData memory payData) internal returns (uint paidAmount) {
        paidAmount = payData.kyberNetworkProxy.tradeWithHint.value(msg.value)({
            src:payData.src,
            srcAmount:payData.srcAmount,
            dest:payData.dest,
            destAddress:payData.destAddress,
            maxDestAmount:payData.maxDestAmount,
            minConversionRate:payData.minConversionRate,
            walletId:payData.walletId,
            hint:payData.hint
        });
    }

    function getBalances (ERC20 src, ERC20 dest, address destAddress)
        internal
        view
        returns (uint wrapperSrcBalance, uint destAddressBalance)
    {
        if (src == ETH_TOKEN_ADDRESS) {
            wrapperSrcBalance = address(this).balance;
        } else {
            wrapperSrcBalance = src.balanceOf(address(this));
        }

        if (dest == ETH_TOKEN_ADDRESS) {
            destAddressBalance = destAddress.balance;
        } else {
            destAddressBalance = dest.balanceOf(destAddress);
        }
    } 
}