pragma solidity ^0.4.18;







contract MyWishCrowdsale is usingMyWishConsts, FinalizableCrowdsale {
    MyWishRateProviderI public rateProvider;

    function MyWishCrowdsale(
            uint _startTime,
            uint _endTime,
            uint _hardCapTokens
    )
            FinalizableCrowdsale(_startTime, _endTime, _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, COLD_WALLET) {

        token.mint(TEAM_ADDRESS, TEAM_TOKENS);
        token.mint(BOUNTY_ADDRESS, BOUNTY_TOKENS);
        token.mint(PREICO_ADDRESS, PREICO_TOKENS);

        MyWishToken(token).addExcluded(TEAM_ADDRESS);
        MyWishToken(token).addExcluded(BOUNTY_ADDRESS);
        MyWishToken(token).addExcluded(PREICO_ADDRESS);

        MyWishRateProvider provider = new MyWishRateProvider();
        provider.transferOwnership(owner);
        rateProvider = provider;
    }

    


    function createTokenContract() internal returns (MintableToken) {
        return new MyWishToken();
    }

    


    function getRate(uint _value) internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, _value);
    }

    function getBaseRate() internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, MINIMAL_PURCHASE);
    }

    


    function getRateScale() internal constant returns (uint) {
        return rateProvider.getRateScale();
    }

    



    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0);
        rateProvider = MyWishRateProviderI(_rateProviderAddress);
    }

    



    function setEndTime(uint _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = uint32(_endTime);
    }

    function setHardCap(uint _hardCapTokens) onlyOwner notFinalized {
        require(_hardCapTokens * TOKEN_DECIMAL_MULTIPLIER > hardCap);
        hardCap = _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER;
    }

    function setStartTime(uint _startTime) onlyOwner notFinalized {
        require(_startTime < endTime);
        startTime = uint32(_startTime);
    }

    function addExcluded(address _address) onlyOwner notFinalized {
        MyWishToken(token).addExcluded(_address);
    }

    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        if (_amountWei < MINIMAL_PURCHASE) {
            return false;
        }
        return super.validPurchase(_amountWei, _actualRate, _totalSupply);
    }

    function finalization() internal {
        super.finalization();
        token.finishMinting();
        MyWishToken(token).crowdsaleFinished();
        token.transferOwnership(owner);
    }
}