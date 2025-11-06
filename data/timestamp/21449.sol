

pragma solidity ^0.5.0;






contract LockingEth4Reputation is Locking4Reputation {

    











    function initialize(
        Avatar _avatar,
        uint256 _reputationReward,
        uint256 _lockingStartTime,
        uint256 _lockingEndTime,
        uint256 _redeemEnableTime,
        uint256 _maxLockingPeriod)
    external
    {
        super._initialize(
        _avatar,
        _reputationReward,
        _lockingStartTime,
        _lockingEndTime,
        _redeemEnableTime,
        _maxLockingPeriod);
    }

    





    function release(address payable _beneficiary, bytes32 _lockingId) public returns(bool) {
        uint256 amount = super._release(_beneficiary, _lockingId);
        _beneficiary.transfer(amount);

        return true;
    }

    




    function lock(uint256 _period) public payable returns(bytes32 lockingId) {
        return super._lock(msg.value, _period, msg.sender, 1, 1);
    }

}



pragma solidity ^0.5.4;




