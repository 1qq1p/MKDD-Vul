pragma solidity ^0.4.22;












library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;

        return c;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }

    function plus(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}






contract PresaleFundraiser is MintableTokenFundraiser {
    
    uint256 public presaleSupply;

    
    uint256 public presaleMaxSupply;

    
    uint256 public presaleStartTime;

    
    uint256 public presaleEndTime;

    
    uint256 public presaleConversionRate;

    






    function initializePresaleFundraiser(
        uint256 _presaleMaxSupply,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate
    )
        internal
    {
        require(_endTime >= _startTime, "Pre-sale's end is before its start");
        require(_conversionRate > 0, "Conversion rate is not set");

        presaleMaxSupply = _presaleMaxSupply;
        presaleStartTime = _startTime;
        presaleEndTime = _endTime;
        presaleConversionRate = _conversionRate;
    }

    


    
    function isPresaleActive() internal view returns (bool) {
        return now < presaleEndTime && now >= presaleStartTime;
    }
    


    function getConversionRate() public view returns (uint256) {
        if (isPresaleActive()) {
            return presaleConversionRate;
        }
        return super.getConversionRate();
    }

    


    function validateTransaction() internal view {
        require(msg.value != 0, "Transaction value is zero");
        require(
            now >= startTime && now < endTime || isPresaleActive(),
            "Neither the pre-sale nor the fundraiser are currently active"
        );
    }

    function handleTokens(address _address, uint256 _tokens) internal {
        if (isPresaleActive()) {
            presaleSupply = presaleSupply.plus(_tokens);
            require(
                presaleSupply <= presaleMaxSupply,
                "Transaction exceeds the pre-sale maximum token supply"
            );
        }

        super.handleTokens(_address, _tokens);
    }

}








