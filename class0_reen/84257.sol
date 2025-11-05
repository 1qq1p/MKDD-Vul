pragma solidity 0.4.24;
pragma experimental "v0.5.0";





















contract PositionGetters is MarginStorage {
    using SafeMath for uint256;

    

    





    function containsPosition(
        bytes32 positionId
    )
        external
        view
        returns (bool)
    {
        return MarginCommon.containsPositionImpl(state, positionId);
    }

    





    function isPositionCalled(
        bytes32 positionId
    )
        external
        view
        returns (bool)
    {
        return (state.positions[positionId].callTimestamp > 0);
    }

    





    function isPositionClosed(
        bytes32 positionId
    )
        external
        view
        returns (bool)
    {
        return state.closedPositions[positionId];
    }

    





    function getTotalOwedTokenRepaidToLender(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        return state.totalOwedTokenRepaidToLender[positionId];
    }

    





    function getPositionBalance(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        return MarginCommon.getPositionBalanceImpl(state, positionId);
    }

    







    function getTimeUntilInterestIncrease(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        uint256 effectiveTimeElapsed = MarginCommon.calculateEffectiveTimeElapsed(
            position,
            block.timestamp
        );

        uint256 absoluteTimeElapsed = block.timestamp.sub(position.startTimestamp);
        if (absoluteTimeElapsed > effectiveTimeElapsed) { 
            return 0;
        } else {
            
            
            return effectiveTimeElapsed.add(1).sub(absoluteTimeElapsed);
        }
    }

    






    function getPositionOwedAmount(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        return MarginCommon.calculateOwedAmount(
            position,
            position.principal,
            block.timestamp
        );
    }

    








    function getPositionOwedAmountAtTime(
        bytes32 positionId,
        uint256 principalToClose,
        uint32  timestamp
    )
        external
        view
        returns (uint256)
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        require(
            timestamp >= position.startTimestamp,
            "PositionGetters#getPositionOwedAmountAtTime: Requested time before position started"
        );

        return MarginCommon.calculateOwedAmount(
            position,
            principalToClose,
            timestamp
        );
    }

    








    function getLenderAmountForIncreasePositionAtTime(
        bytes32 positionId,
        uint256 principalToAdd,
        uint32  timestamp
    )
        external
        view
        returns (uint256)
    {
        MarginCommon.Position storage position =
            MarginCommon.getPositionFromStorage(state, positionId);

        require(
            timestamp >= position.startTimestamp,
            "PositionGetters#getLenderAmountForIncreasePositionAtTime: timestamp < position start"
        );

        return MarginCommon.calculateLenderAmountForIncreasePosition(
            position,
            principalToAdd,
            timestamp
        );
    }

    

    

























    function getPosition(
        bytes32 positionId
    )
        external
        view
        returns (
            address[4],
            uint256[2],
            uint32[6]
        )
    {
        MarginCommon.Position storage position = state.positions[positionId];

        return (
            [
                position.owedToken,
                position.heldToken,
                position.lender,
                position.owner
            ],
            [
                position.principal,
                position.requiredDeposit
            ],
            [
                position.callTimeLimit,
                position.startTimestamp,
                position.callTimestamp,
                position.maxDuration,
                position.interestRate,
                position.interestPeriod
            ]
        );
    }

    

    function getPositionLender(
        bytes32 positionId
    )
        external
        view
        returns (address)
    {
        return state.positions[positionId].lender;
    }

    function getPositionOwner(
        bytes32 positionId
    )
        external
        view
        returns (address)
    {
        return state.positions[positionId].owner;
    }

    function getPositionHeldToken(
        bytes32 positionId
    )
        external
        view
        returns (address)
    {
        return state.positions[positionId].heldToken;
    }

    function getPositionOwedToken(
        bytes32 positionId
    )
        external
        view
        returns (address)
    {
        return state.positions[positionId].owedToken;
    }

    function getPositionPrincipal(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        return state.positions[positionId].principal;
    }

    function getPositionInterestRate(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        return state.positions[positionId].interestRate;
    }

    function getPositionRequiredDeposit(
        bytes32 positionId
    )
        external
        view
        returns (uint256)
    {
        return state.positions[positionId].requiredDeposit;
    }

    function getPositionStartTimestamp(
        bytes32 positionId
    )
        external
        view
        returns (uint32)
    {
        return state.positions[positionId].startTimestamp;
    }

    function getPositionCallTimestamp(
        bytes32 positionId
    )
        external
        view
        returns (uint32)
    {
        return state.positions[positionId].callTimestamp;
    }

    function getPositionCallTimeLimit(
        bytes32 positionId
    )
        external
        view
        returns (uint32)
    {
        return state.positions[positionId].callTimeLimit;
    }

    function getPositionMaxDuration(
        bytes32 positionId
    )
        external
        view
        returns (uint32)
    {
        return state.positions[positionId].maxDuration;
    }

    function getPositioninterestPeriod(
        bytes32 positionId
    )
        external
        view
        returns (uint32)
    {
        return state.positions[positionId].interestPeriod;
    }
}










library TransferImpl {

    

    function transferLoanImpl(
        MarginState.State storage state,
        bytes32 positionId,
        address newLender
    )
        public
    {
        require(
            MarginCommon.containsPositionImpl(state, positionId),
            "TransferImpl#transferLoanImpl: Position does not exist"
        );

        address originalLender = state.positions[positionId].lender;

        require(
            msg.sender == originalLender,
            "TransferImpl#transferLoanImpl: Only lender can transfer ownership"
        );
        require(
            newLender != originalLender,
            "TransferImpl#transferLoanImpl: Cannot transfer ownership to self"
        );

        
        
        address finalLender = TransferInternal.grantLoanOwnership(
            positionId,
            originalLender,
            newLender);

        require(
            finalLender != originalLender,
            "TransferImpl#transferLoanImpl: Cannot ultimately transfer ownership to self"
        );

        
        state.positions[positionId].lender = finalLender;
    }

    function transferPositionImpl(
        MarginState.State storage state,
        bytes32 positionId,
        address newOwner
    )
        public
    {
        require(
            MarginCommon.containsPositionImpl(state, positionId),
            "TransferImpl#transferPositionImpl: Position does not exist"
        );

        address originalOwner = state.positions[positionId].owner;

        require(
            msg.sender == originalOwner,
            "TransferImpl#transferPositionImpl: Only position owner can transfer ownership"
        );
        require(
            newOwner != originalOwner,
            "TransferImpl#transferPositionImpl: Cannot transfer ownership to self"
        );

        
        
        address finalOwner = TransferInternal.grantPositionOwnership(
            positionId,
            originalOwner,
            newOwner);

        require(
            finalOwner != originalOwner,
            "TransferImpl#transferPositionImpl: Cannot ultimately transfer ownership to self"
        );

        
        state.positions[positionId].owner = finalOwner;
    }
}








