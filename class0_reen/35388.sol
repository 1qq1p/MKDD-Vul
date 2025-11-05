

















pragma solidity ^0.4.23;







contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    
    
{
    event Initialized();
    event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);
    bool public initialized = false;

    constructor(MintableToken _token) public
        Crowdsale(2500 * TOKEN_DECIMAL_MULTIPLIER, 0x17B578b9315C377aCdA93317e3C380BB0C620E6c, _token)
        TimedCrowdsale(START_TIME > now ? START_TIME : now, 1561935540)
        CappedCrowdsale(1200000000000000000000000)
        
    {
    }

    function init() public onlyOwner {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            MainToken(token).pause();
        }

        
        address[1] memory addresses = [address(0x17b578b9315c377acda93317e3c380bb0c620e6c)];
        uint[1] memory amounts = [uint(7000000000000000000000000000)];
        uint64[1] memory freezes = [uint64(0)];

        for (uint i = 0; i < addresses.length; i++) {
            if (freezes[i] == 0) {
                MainToken(token).mint(addresses[i], amounts[i]);
            } else {
                MainToken(token).mintAndFreeze(addresses[i], amounts[i], freezes[i]);
            }
        }
        

        transferOwnership(TARGET_USER);

        emit Initialized();
    }

    

    

    
    function setEndTime(uint _endTime) public onlyOwner {
        
        require(now < closingTime);
        
        require(now < _endTime);
        require(_endTime > openingTime);
        emit TimesChanged(openingTime, _endTime, openingTime, closingTime);
        closingTime = _endTime;
    }
    

    

    

    
}