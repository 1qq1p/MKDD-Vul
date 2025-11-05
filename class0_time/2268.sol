pragma solidity ^0.4.18;



contract InsightsNetwork2 is InsightsNetwork2Base {

    function importBalanceOf(address account) public onlyOwner canMint returns (bool) {
        require(!imported[account]);
        uint256 amount = InsightsNetwork1(predecessor).balances(account)*ATTOTOKEN_FACTOR;
        require(amount > 0);
        uint256 unlockTime = InsightsNetwork1(predecessor).unlockTimes(account);
        imported[account] = true;
        Import(account, amount, unlockTime);
        return mintUnlockTime(account, amount, unlockTime);
    }

    function relock(address account, uint256 amount, uint256 oldUnlockTime, int256 lockPeriod) public onlyOwner canMint returns (bool) {
        
        if (lockPeriod < 0)
            lockPeriod = 1 years;
        for (uint index = 0; index < lockedBalances[account].length; index++)
            if (lockedBalances[account][index] == amount && unlockTimes[account][index] == oldUnlockTime) {
                unlockTimes[account][index] = now + uint256(lockPeriod);
                return true;
            }
        return false;
    }

    function relockPart(address account, uint256 amount, uint256 unlockTime, uint256 partAmount, int256 partLockPeriod) public onlyOwner canMint returns (bool) {
        
        require(partAmount > 0);
        require(partAmount < amount);
        if (partLockPeriod < 0)
            partLockPeriod = 1 years;
        for (uint index = 0; index < lockedBalances[account].length; index++)
            if (lockedBalances[account][index] == amount && unlockTimes[account][index] == unlockTime) {
                lockedBalances[account][index] -= partAmount;
                lockedBalances[account].push(partAmount);
                unlockTimes[account].push(now + uint256(partLockPeriod));
                return true;
            }
        return false;
    }

    function predecessorDeactivated(address _predecessor) internal onlyOwner returns (bool) {
        return !InsightsNetwork1(_predecessor).active();
    }

}