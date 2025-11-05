pragma solidity ^0.4.18;







contract BonusableCrowdsale is usingConsts, Crowdsale {

    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        
        uint256 bonusRate = getBonusRate(weiAmount);
        uint256 tokens = weiAmount.mul(bonusRate).div(1 ether);

        
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function getBonusRate(uint256 weiAmount) internal returns (uint256) {
        uint256 bonusRate = rate;

        
        
        uint[1] memory weiRaisedStartsBoundaries = [uint(2000000000000000000)];
        uint[1] memory weiRaisedEndsBoundaries = [uint(18333333333333333333333)];
        uint64[1] memory timeStartsBoundaries = [uint64(1521676848)];
        uint64[1] memory timeEndsBoundaries = [uint64(1530751135)];
        uint[1] memory weiRaisedAndTimeRates = [uint(360)];

        for (uint i = 0; i < 1; i++) {
            bool weiRaisedInBound = (weiRaisedStartsBoundaries[i] <= weiRaised) && (weiRaised < weiRaisedEndsBoundaries[i]);
            bool timeInBound = (timeStartsBoundaries[i] <= now) && (now < timeEndsBoundaries[i]);
            if (weiRaisedInBound && timeInBound) {
                bonusRate += bonusRate * weiRaisedAndTimeRates[i] / 1000;
            }
        }
        

        
        
        uint[2] memory weiAmountBoundaries = [uint(18333000000000000000000),uint(10000000000000000000)];
        uint[2] memory weiAmountRates = [uint(0),uint(50)];

        for (uint j = 0; j < 2; j++) {
            if (weiAmount >= weiAmountBoundaries[j]) {
                bonusRate += bonusRate * weiAmountRates[j] / 1000;
                break;
            }
        }
        

        return bonusRate;
    }
}


