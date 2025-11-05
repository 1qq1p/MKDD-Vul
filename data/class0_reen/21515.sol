pragma solidity ^0.4.24;






contract PoolDaonomicCrowdsale is Ownable, MintingDaonomicCrowdsale {
    event PoolCreatedEvent(string name, uint maxAmount, uint start, uint vestingInterval, uint value);
    event TokenHolderCreatedEvent(string name, address addr, uint amount);

    mapping(string => PoolDescription) pools;

    struct PoolDescription {
        


        uint maxAmount;
        


        uint releasedAmount;
        


        uint start;
        


        uint vestingInterval;
        


        uint value;
    }

    constructor(MintableToken _token) MintingDaonomicCrowdsale(_token) public {

    }

    function registerPool(string _name, uint _maxAmount, uint _start, uint _vestingInterval, uint _value) internal {
        require(_maxAmount > 0, "maxAmount should be greater than 0");
        require(_vestingInterval > 0, "vestingInterval should be greater than 0");
        require(_value > 0 && _value <= 100, "value should be >0 and <=100");
        pools[_name] = PoolDescription(_maxAmount, 0, _start, _vestingInterval, _value);
        emit PoolCreatedEvent(_name, _maxAmount, _start, _vestingInterval, _value);
    }

    function releaseTokens(string _name, address _beneficiary, uint _amount) onlyOwner public returns (TokenHolder) {
        PoolDescription storage pool = pools[_name];
        require(pool.maxAmount != 0, "pool is not defined");
        require(_amount.add(pool.releasedAmount) <= pool.maxAmount, "pool is depleted");
        pool.releasedAmount = _amount.add(pool.releasedAmount);
        TokenHolder created = new TokenHolder(pool.start, pool.vestingInterval, _amount.mul(pool.value).div(100), token);
        created.transferOwnership(_beneficiary);
        token.mint(created, _amount);
        emit TokenHolderCreatedEvent(_name, created, _amount);
        return created;
    }

    function getTokensLeft(string _name) view public returns (uint) {
        PoolDescription storage pool = pools[_name];
        require(pool.maxAmount != 0, "pool is not defined");
        return pool.maxAmount.sub(pool.releasedAmount);
    }
}




