




















pragma solidity ^0.4.21;













contract LimitedSetup {

    uint constructionTime;
    uint setupDuration;

    function LimitedSetup(uint _setupDuration)
        public
    {
        constructionTime = now;
        setupDuration = _setupDuration;
    }

    modifier setupFunction
    {
        require(now < constructionTime + setupDuration);
        _;
    }
}

















