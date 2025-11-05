pragma solidity ^0.4.24;








contract MilestoneLockToken is StandardToken, Ownable {
    using SafeMath for uint256;

    struct Policy {
        uint256 kickOff;
        uint256[] periods;
        uint8[] percentages;
    }

    struct MilestoneLock {
        uint8[] policies;
        uint256[] standardBalances;
    }

    uint8 constant MAX_POLICY = 100;
    uint256 constant MAX_PERCENTAGE = 100;

    mapping(uint8 => Policy) internal policies;
    mapping(address => MilestoneLock) internal milestoneLocks;

    event SetPolicyKickOff(uint8 policy, uint256 kickOff);
    event PolicyAdded(uint8 policy);
    event PolicyRemoved(uint8 policy);
    event PolicyAttributeAdded(uint8 policy, uint256 period, uint8 percentage);
    event PolicyAttributeRemoved(uint8 policy, uint256 period);
    event PolicyAttributeModified(uint8 policy, uint256 period, uint8 percentage);

    




    function transfer(address _to, uint256 _value) public
        returns (bool)
    {
        require(getAvailableBalance(msg.sender) >= _value);

        return super.transfer(_to, _value);
    }

    





    function transferFrom(address _from, address _to, uint256 _value) public
        returns (bool)
    {
        require(getAvailableBalance(_from) >= _value);

        return super.transferFrom(_from, _to, _value);
    }

    





    function distributeWithPolicy(address _to, uint256 _value, uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[owner]);
        require(_policy < MAX_POLICY);
        require(policies[_policy].periods.length > 0);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);

        uint8 policyIndex = _getAppliedPolicyIndex(_to, _policy);
        if (policyIndex < MAX_POLICY) {
            milestoneLocks[_to].standardBalances[policyIndex] = 
                milestoneLocks[_to].standardBalances[policyIndex].add(_value);
        } else {
            milestoneLocks[_to].policies.push(_policy);
            milestoneLocks[_to].standardBalances.push(_value);
        }

        emit Transfer(owner, _to, _value);

        return true;
    }

    





    function addPolicy(uint8 _policy, uint256[] _periods, uint8[] _percentages) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);
        require(_periods.length > 0);
        require(_percentages.length > 0);
        require(_periods.length == _percentages.length);
        require(policies[_policy].periods.length == 0);

        policies[_policy].periods = _periods;
        policies[_policy].percentages = _percentages;

        emit PolicyAdded(_policy);

        return true;
    }

    



    function removePolicy(uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);

        delete policies[_policy];

        emit PolicyRemoved(_policy);

        return true;
    }

    



    function getPolicy(uint8 _policy) public
        view
        returns (uint256 kickOff, uint256[] periods, uint8[] percentages)
    {
        require(_policy < MAX_POLICY);

        return (
            policies[_policy].kickOff,
            policies[_policy].periods,
            policies[_policy].percentages
        );
    }

    




    function setKickOff(uint8 _policy, uint256 _time) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);
        require(policies[_policy].periods.length > 0);

        policies[_policy].kickOff = _time;

        return true;
    }

    





    function addPolicyAttribute(uint8 _policy, uint256 _period, uint8 _percentage) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);

        Policy storage policy = policies[_policy];

        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                revert();
                return false;
            }
        }

        policy.periods.push(_period);
        policy.percentages.push(_percentage);

        emit PolicyAttributeAdded(_policy, _period, _percentage);

        return true;
    }

    




    function removePolicyAttribute(uint8 _policy, uint256 _period) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);

        Policy storage policy = policies[_policy];
        
        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                _removeElementAt256(policy.periods, i);
                _removeElementAt8(policy.percentages, i);

                emit PolicyAttributeRemoved(_policy, _period);

                return true;
            }
        }

        revert();

        return false;
    }

    





    function modifyPolicyAttribute(uint8 _policy, uint256 _period, uint8 _percentage) public
        onlyOwner
        returns (bool)
    {
        require(_policy < MAX_POLICY);

        Policy storage policy = policies[_policy];
        for (uint256 i = 0; i < policy.periods.length; i++) {
            if (policy.periods[i] == _period) {
                policy.percentages[i] = _percentage;

                emit PolicyAttributeModified(_policy, _period, _percentage);

                return true;
            }
        }

        revert();

        return false;
    }

    



    function getPolicyLockedPercentage(uint8 _policy) public view
        returns (uint256)
    {
        require(_policy < MAX_POLICY);

        Policy storage policy = policies[_policy];

        if (policy.periods.length == 0) {
            return 0;
        }
        
        if (policy.kickOff == 0 ||
            policy.kickOff > now) {
            return MAX_PERCENTAGE;
        }

        uint256 unlockedPercentage = 0;
        for (uint256 i = 0; i < policy.periods.length; ++i) {
            if (policy.kickOff.add(policy.periods[i]) <= now) {
                unlockedPercentage =
                    unlockedPercentage.add(policy.percentages[i]);
            }
        }

        if (unlockedPercentage > MAX_PERCENTAGE) {
            return 0;
        }

        return MAX_PERCENTAGE.sub(unlockedPercentage);
    }

    





    function modifyMilestoneTo(address _to, uint8 _prevPolicy, uint8 _newPolicy) public
        onlyOwner
        returns (bool)
    {
        require(_to != address(0));
        require(_prevPolicy < MAX_POLICY);
        require(_newPolicy < MAX_POLICY);
        require(_prevPolicy != _newPolicy);
        require(policies[_prevPolicy].periods.length > 0);
        require(policies[_newPolicy].periods.length > 0);

        uint256 prevPolicyIndex = _getAppliedPolicyIndex(_to, _prevPolicy);
        require(prevPolicyIndex < MAX_POLICY);

        MilestoneLock storage milestoneLock = milestoneLocks[_to];

        uint256 prevLockedBalance = milestoneLock.standardBalances[prevPolicyIndex];

        uint256 newPolicyIndex = _getAppliedPolicyIndex(_to, _newPolicy);
        if (newPolicyIndex < MAX_POLICY) {
            milestoneLock.standardBalances[newPolicyIndex] =
                milestoneLock.standardBalances[newPolicyIndex].add(prevLockedBalance);

            _removeElementAt8(milestoneLock.policies, prevPolicyIndex);
            _removeElementAt256(milestoneLock.standardBalances, prevPolicyIndex);
        } else {
            milestoneLock.policies.push(_newPolicy);
            milestoneLock.standardBalances.push(prevLockedBalance);
        }

        return true;
    }

    




    function removeMilestoneFrom(address _from, uint8 _policy) public
        onlyOwner
        returns (bool)
    {
        require(_from != address(0));
        require(_policy < MAX_POLICY);

        uint256 policyIndex = _getAppliedPolicyIndex(_from, _policy);
        require(policyIndex < MAX_POLICY);

        _removeElementAt8(milestoneLocks[_from].policies, policyIndex);
        _removeElementAt256(milestoneLocks[_from].standardBalances, policyIndex);

        return true;
    }

    



    function getUserMilestone(address _account) public
        view
        returns (uint8[] accountPolicies, uint256[] accountStandardBalances)
    {
        return (
            milestoneLocks[_account].policies,
            milestoneLocks[_account].standardBalances
        );
    }

    



    function getAvailableBalance(address _account) public
        view
        returns (uint256)
    {
        return balances[_account].sub(getTotalLockedBalance(_account));
    }

    




    function getLockedBalance(address _account, uint8 _policy) public
        view
        returns (uint256)
    {
        require(_policy < MAX_POLICY);

        uint256 policyIndex = _getAppliedPolicyIndex(_account, _policy);
        if (policyIndex >= MAX_POLICY) {
            return 0;
        }

        MilestoneLock storage milestoneLock = milestoneLocks[_account];

        uint256 lockedPercentage =
            getPolicyLockedPercentage(milestoneLock.policies[policyIndex]);
        return milestoneLock.standardBalances[policyIndex].div(MAX_PERCENTAGE).mul(lockedPercentage);
    }

    



    function getTotalLockedBalance(address _account) public
        view
        returns (uint256)
    {
        MilestoneLock storage milestoneLock = milestoneLocks[_account];

        uint256 totalLockedBalance = 0;
        for (uint256 i = 0; i < milestoneLock.policies.length; i++) {
            totalLockedBalance = totalLockedBalance.add(
                getLockedBalance(_account, milestoneLock.policies[i])
            );
        }

        return totalLockedBalance;
    }

    




    function _getAppliedPolicyIndex(address _to, uint8 _policy) internal
        view
        returns (uint8)
    {
        require(_policy < MAX_POLICY);

        MilestoneLock storage milestoneLock = milestoneLocks[_to];
        for (uint8 i = 0; i < milestoneLock.policies.length; i++) {
            if (milestoneLock.policies[i] == _policy) {
                return i;
            }
        }

        return MAX_POLICY;
    }

    




    function _removeElementAt256(uint256[] storage _array, uint256 _index) internal
        returns (bool)
    {
        if (_array.length <= _index) {
            return false;
        }

        for (uint256 i = _index; i < _array.length - 1; i++) {
            _array[i] = _array[i + 1];
        }

        delete _array[_array.length - 1];
        _array.length--;

        return true;
    }

    




    function _removeElementAt8(uint8[] storage _array, uint256 _index) internal
        returns (bool)
    {
        if (_array.length <= _index) {
            return false;
        }

        for (uint256 i = _index; i < _array.length - 1; i++) {
            _array[i] = _array[i + 1];
        }

        delete _array[_array.length - 1];
        _array.length--;

        return true;
    }
}





