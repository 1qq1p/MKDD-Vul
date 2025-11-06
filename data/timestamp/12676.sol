pragma solidity ^0.4.19;





contract Beercoin is MasteredBeercoin {
    event Produce(uint256 newCaps);
    event Scan(address[] users, uint256[] caps);
    event Burn(uint256 value);

    



    function Beercoin() public {
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    








    function produce(uint64 numberOfCaps) public onlyMaster returns (bool) {
        require(numberOfCaps <= producibleCaps);

        uint256 producedCaps = packedProducedCaps;

        uint64 targetTotalCaps = numberOfCaps;
        targetTotalCaps += uint64(producedCaps >> 192);
        targetTotalCaps += uint64(producedCaps >> 128);
        targetTotalCaps += uint64(producedCaps >> 64);
        targetTotalCaps += uint64(producedCaps);

        uint64 targetDiamondCaps = (targetTotalCaps - (targetTotalCaps % 10000)) / 10000;
        uint64 targetGoldCaps = ((targetTotalCaps - (targetTotalCaps % 1000)) / 1000) - targetDiamondCaps;
        uint64 targetSilverCaps = ((targetTotalCaps - (targetTotalCaps % 10)) / 10) - targetDiamondCaps - targetGoldCaps;
        uint64 targetBronzeCaps = targetTotalCaps - targetDiamondCaps - targetGoldCaps - targetSilverCaps;

        uint256 targetProducedCaps = 0;
        targetProducedCaps |= uint256(targetDiamondCaps) << 192;
        targetProducedCaps |= uint256(targetGoldCaps) << 128;
        targetProducedCaps |= uint256(targetSilverCaps) << 64;
        targetProducedCaps |= uint256(targetBronzeCaps);

        producibleCaps -= numberOfCaps;
        packedProducedCaps = targetProducedCaps;

        Produce(targetProducedCaps - producedCaps);

        return true;
    }

    









    function scan(address[] users, uint256[] caps) public onlyMaster returns (bool) {
        require(users.length == caps.length);

        uint256 scannedCaps = packedScannedCaps;

        uint256 currentCaps;
        uint256 capsValue;
        for (uint256 i = 0; i < users.length; ++i) {
            currentCaps = caps[i];

            capsValue = DIAMOND_VALUE * (currentCaps >> 192);
            capsValue += GOLD_VALUE * ((currentCaps >> 128) & 0xFFFFFFFFFFFFFFFF);
            capsValue += SILVER_VALUE * ((currentCaps >> 64) & 0xFFFFFFFFFFFFFFFF);
            capsValue += BRONZE_VALUE * (currentCaps & 0xFFFFFFFFFFFFFFFF);

            balances[users[i]] += capsValue;
            scannedCaps += currentCaps;
        }

        require(scannedCaps <= packedProducedCaps);
        packedScannedCaps = scannedCaps;

        Scan(users, caps);

        return true;
    }

    




    function burn(uint256 value) public onlyMaster returns (bool) {
        uint256 balance = balances[msg.sender];
        require(value <= balance);

        balances[msg.sender] = balance - value;
        burntValue += value;

        Burn(value);

        return true;
    }
}