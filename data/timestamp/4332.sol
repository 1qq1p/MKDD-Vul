

















pragma solidity ^0.4.23;







contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    
    , Checkable
    
    
    , WhitelistedCrowdsale
    
{
    event Initialized();
    event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);
    bool public initialized = false;

    constructor(MintableToken _token) public
        Crowdsale(8000 * TOKEN_DECIMAL_MULTIPLIER, 0xbC5F8A2d64026248EA2C3Aef800F96fB659cf027, _token)
        TimedCrowdsale(START_TIME > now ? START_TIME : now, 1535472000)
        CappedCrowdsale(62500000000000000000000)
        
    {
    }

    function init() public onlyOwner {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            MainToken(token).pause();
        }

        

        transferOwnership(TARGET_USER);

        emit Initialized();
    }

    
    



    function hasClosed() public view returns (bool) {
        bool remainValue = cap.sub(weiRaised) < 230000000000000000;
        return super.hasClosed() || remainValue;
    }
    

    

    

    

    
    



    function internalCheck() internal returns (bool) {
        bool result = !isFinalized && hasClosed();
        emit Checked(result);
        return result;
    }

    


    function internalAction() internal {
        finalization();
        emit Finalized();

        isFinalized = true;
    }
    

    
    



    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
    {
        
        require(msg.value >= 230000000000000000);
        
        
        require(msg.value <= 575000000000000000000);
        
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }
    
}