



 
pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;







contract OracleNotifierInterface {

    function closeLoanNotifier(
        BZxObjects.LoanOrder memory loanOrder,
        BZxObjects.LoanPosition memory loanPosition,
        address loanCloser,
        uint256 closeAmount,
        bool isLiquidation)
        public
        returns (bool);
}

interface IBZx {
    function pushLoanOrderOnChain(
        address[8] calldata orderAddresses,
        uint256[11] calldata orderValues,
        bytes calldata oracleData,
        bytes calldata signature)
        external
        returns (bytes32); 

    function setLoanOrderDesc(
        bytes32 loanOrderHash,
        string calldata desc)
        external
        returns (bool);

    function updateLoanAsLender(
        bytes32 loanOrderHash,
        uint256 increaseAmountForLoan,
        uint256 newInterestRate,
        uint256 newExpirationTimestamp)
        external
        returns (bool);

    function takeLoanOrderOnChainAsTraderByDelegate(
        address trader,
        bytes32 loanOrderHash,
        address collateralTokenFilled,
        uint256 loanTokenAmountFilled,
        address tradeTokenToFillAddress,
        bool withdrawOnOpen)
        external
        returns (uint256);

    function getLenderInterestForOracle(
        address lender,
        address oracleAddress,
        address interestTokenAddress)
        external
        view
        returns (
            uint256,    
            uint256,    
            uint256,    
            uint256);   

    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);
}

interface IBZxOracle {
    function tradeUserAsset(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        address returnToSenderAddress,
        uint256 sourceTokenAmount,
        uint256 maxDestTokenAmount,
        uint256 minConversionRate)
        external
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed);

    function interestFeePercent()
        external
        view
        returns (uint256);
}

interface iTokenizedRegistry {
    function getTokenAsset(
        address _token,
        uint256 _tokenType)
        external
        view
        returns (address);
}
