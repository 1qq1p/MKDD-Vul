pragma solidity ^0.4.23;

























contract MainCrowdsale is Consts, FinalizableCrowdsale, MintedCrowdsale, CappedCrowdsale {
    function hasStarted() public view returns (bool) {
        return now >= openingTime;
    }

    function startTime() public view returns (uint256) {
        return openingTime;
    }

    function endTime() public view returns (uint256) {
        return closingTime;
    }

    function hasClosed() public view returns (bool) {
        return super.hasClosed() || capReached();
    }

    function hasEnded() public view returns (bool) {
        return hasClosed();
    }

    function finalization() internal {
        super.finalization();

        if (PAUSED) {
            MainToken(token).unpause();
        }

        if (!CONTINUE_MINTING) {
            require(MintableToken(token).finishMinting());
        }

        Ownable(token).transferOwnership(TARGET_USER);
    }

    




    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        return _weiAmount.mul(rate).div(1 ether);
    }
}

