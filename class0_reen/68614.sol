pragma solidity 0.4.24;
pragma experimental "v0.5.0";



contract LoanGetters is MarginStorage {

    

    






    function getLoanUnavailableAmount(
        bytes32 loanHash
    )
        external
        view
        returns (uint256)
    {
        return MarginCommon.getUnavailableLoanOfferingAmountImpl(state, loanHash);
    }

    





    function getLoanFilledAmount(
        bytes32 loanHash
    )
        external
        view
        returns (uint256)
    {
        return state.loanFills[loanHash];
    }

    





    function getLoanCanceledAmount(
        bytes32 loanHash
    )
        external
        view
        returns (uint256)
    {
        return state.loanCancels[loanHash];
    }
}













interface CancelMarginCallDelegator {

    

    









    function cancelMarginCallOnBehalfOf(
        address canceler,
        bytes32 positionId
    )
        external
        
        returns (address);
}













interface MarginCallDelegator {

    

    










    function marginCallOnBehalfOf(
        address caller,
        bytes32 positionId,
        uint256 depositAmount
    )
        external
        
        returns (address);
}













library LoanImpl {
    using SafeMath for uint256;

    

    


    event MarginCallInitiated(
        bytes32 indexed positionId,
        address indexed lender,
        address indexed owner,
        uint256 requiredDeposit
    );

    


    event MarginCallCanceled(
        bytes32 indexed positionId,
        address indexed lender,
        address indexed owner,
        uint256 depositAmount
    );

    



    event LoanOfferingCanceled(
        bytes32 indexed loanHash,
        address indexed payer,
        address indexed feeRecipient,
        uint256 cancelAmount
    );

    

    function marginCallImpl(
        MarginState.State storage state,
        bytes32 positionId,
        uint256 requiredDeposit
    )
        public
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        require(
            position.callTimestamp == 0,
            "LoanImpl#marginCallImpl: The position has already been margin-called"
        );

        
        marginCallOnBehalfOfRecurse(
            position.lender,
            msg.sender,
            positionId,
            requiredDeposit
        );

        position.callTimestamp = TimestampHelper.getBlockTimestamp32();
        position.requiredDeposit = requiredDeposit;

        emit MarginCallInitiated(
            positionId,
            position.lender,
            position.owner,
            requiredDeposit
        );
    }

    function cancelMarginCallImpl(
        MarginState.State storage state,
        bytes32 positionId
    )
        public
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        require(
            position.callTimestamp > 0,
            "LoanImpl#cancelMarginCallImpl: Position has not been margin-called"
        );

        
        cancelMarginCallOnBehalfOfRecurse(
            position.lender,
            msg.sender,
            positionId
        );

        state.positions[positionId].callTimestamp = 0;
        state.positions[positionId].requiredDeposit = 0;

        emit MarginCallCanceled(
            positionId,
            position.lender,
            position.owner,
            0
        );
    }

    function cancelLoanOfferingImpl(
        MarginState.State storage state,
        address[9] addresses,
        uint256[7] values256,
        uint32[4]  values32,
        uint256    cancelAmount
    )
        public
        returns (uint256)
    {
        MarginCommon.LoanOffering memory loanOffering = parseLoanOffering(
            addresses,
            values256,
            values32
        );

        require(
            msg.sender == loanOffering.payer,
            "LoanImpl#cancelLoanOfferingImpl: Only loan offering payer can cancel"
        );
        require(
            loanOffering.expirationTimestamp > block.timestamp,
            "LoanImpl#cancelLoanOfferingImpl: Loan offering has already expired"
        );

        uint256 remainingAmount = loanOffering.rates.maxAmount.sub(
            MarginCommon.getUnavailableLoanOfferingAmountImpl(state, loanOffering.loanHash)
        );
        uint256 amountToCancel = Math.min256(remainingAmount, cancelAmount);

        
        if (amountToCancel == 0) {
            return 0;
        }

        state.loanCancels[loanOffering.loanHash] =
            state.loanCancels[loanOffering.loanHash].add(amountToCancel);

        emit LoanOfferingCanceled(
            loanOffering.loanHash,
            loanOffering.payer,
            loanOffering.feeRecipient,
            amountToCancel
        );

        return amountToCancel;
    }

    

    function marginCallOnBehalfOfRecurse(
        address contractAddr,
        address who,
        bytes32 positionId,
        uint256 requiredDeposit
    )
        private
    {
        
        if (who == contractAddr) {
            return;
        }

        address newContractAddr =
            MarginCallDelegator(contractAddr).marginCallOnBehalfOf(
                msg.sender,
                positionId,
                requiredDeposit
            );

        if (newContractAddr != contractAddr) {
            marginCallOnBehalfOfRecurse(
                newContractAddr,
                who,
                positionId,
                requiredDeposit
            );
        }
    }

    function cancelMarginCallOnBehalfOfRecurse(
        address contractAddr,
        address who,
        bytes32 positionId
    )
        private
    {
        
        if (who == contractAddr) {
            return;
        }

        address newContractAddr =
            CancelMarginCallDelegator(contractAddr).cancelMarginCallOnBehalfOf(
                msg.sender,
                positionId
            );

        if (newContractAddr != contractAddr) {
            cancelMarginCallOnBehalfOfRecurse(
                newContractAddr,
                who,
                positionId
            );
        }
    }

    

    function parseLoanOffering(
        address[9] addresses,
        uint256[7] values256,
        uint32[4]  values32
    )
        private
        view
        returns (MarginCommon.LoanOffering memory)
    {
        MarginCommon.LoanOffering memory loanOffering = MarginCommon.LoanOffering({
            owedToken: addresses[0],
            heldToken: addresses[1],
            payer: addresses[2],
            owner: addresses[3],
            taker: addresses[4],
            positionOwner: addresses[5],
            feeRecipient: addresses[6],
            lenderFeeToken: addresses[7],
            takerFeeToken: addresses[8],
            rates: parseLoanOfferRates(values256, values32),
            expirationTimestamp: values256[5],
            callTimeLimit: values32[0],
            maxDuration: values32[1],
            salt: values256[6],
            loanHash: 0,
            signature: new bytes(0)
        });

        loanOffering.loanHash = MarginCommon.getLoanOfferingHash(loanOffering);

        return loanOffering;
    }

    function parseLoanOfferRates(
        uint256[7] values256,
        uint32[4] values32
    )
        private
        pure
        returns (MarginCommon.LoanRates memory)
    {
        MarginCommon.LoanRates memory rates = MarginCommon.LoanRates({
            maxAmount: values256[0],
            minAmount: values256[1],
            minHeldToken: values256[2],
            interestRate: values32[2],
            lenderFee: values256[3],
            takerFee: values256[4],
            interestPeriod: values32[3]
        });

        return rates;
    }
}









