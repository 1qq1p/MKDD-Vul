pragma solidity 0.4.25;







contract PlatformTerms is Math, IContractId {

    
    
    

    
    uint256 public constant PLATFORM_FEE_FRACTION = 3 * 10**16;
    
    uint256 public constant TOKEN_PARTICIPATION_FEE_FRACTION = 2 * 10**16;
    
    
    
    uint256 public constant PLATFORM_NEUMARK_SHARE = 2; 
    
    bool public constant IS_ICBM_INVESTOR_WHITELISTED = true;

    
    uint256 public constant MIN_TICKET_EUR_ULPS = 100 * 10**18;
    
    
    

    
    uint256 public constant DATE_TO_WHITELIST_MIN_DURATION = 5 days;
    
    uint256 public constant TOKEN_RATE_EXPIRES_AFTER = 4 hours;

    
    uint256 public constant MIN_WHITELIST_DURATION = 0 days;
    uint256 public constant MAX_WHITELIST_DURATION = 30 days;
    uint256 public constant MIN_PUBLIC_DURATION = 0 days;
    uint256 public constant MAX_PUBLIC_DURATION = 60 days;

    
    uint256 public constant MIN_OFFER_DURATION = 1 days;
    
    uint256 public constant MAX_OFFER_DURATION = 90 days;

    uint256 public constant MIN_SIGNING_DURATION = 14 days;
    uint256 public constant MAX_SIGNING_DURATION = 60 days;

    uint256 public constant MIN_CLAIM_DURATION = 7 days;
    uint256 public constant MAX_CLAIM_DURATION = 30 days;

    
    
    

    
    function calculateNeumarkDistribution(uint256 rewardNmk)
        public
        pure
        returns (uint256 platformNmk, uint256 investorNmk)
    {
        
        platformNmk = rewardNmk / PLATFORM_NEUMARK_SHARE;
        
        return (platformNmk, rewardNmk - platformNmk);
    }

    function calculatePlatformTokenFee(uint256 tokenAmount)
        public
        pure
        returns (uint256)
    {
        
        return proportion(tokenAmount, TOKEN_PARTICIPATION_FEE_FRACTION, 10**18);
    }

    function calculatePlatformFee(uint256 amount)
        public
        pure
        returns (uint256)
    {
        return decimalFraction(amount, PLATFORM_FEE_FRACTION);
    }

    
    
    

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x95482babc4e32de6c4dc3910ee7ae62c8e427efde6bc4e9ce0d6d93e24c39323, 0);
    }
}

