pragma solidity ^0.4.11;






























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

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract BonusCrowdsale is Crowdsale, Ownable {

    
    
    uint32[] public BONUS_TIMES;
    uint32[] public BONUS_TIMES_VALUES;
    uint32[] public BONUS_AMOUNTS;
    uint32[] public BONUS_AMOUNTS_VALUES;
    uint public constant BONUS_COEFF = 1000; 
    
    
    uint public tokenPriceInCents;

    



    function BonusCrowdsale(uint256 _tokenPriceInCents) public {
        tokenPriceInCents = _tokenPriceInCents;
    }

    



    function bonusesForTimesCount() public constant returns(uint) {
        return BONUS_TIMES.length;
    }

    


    function setBonusesForTimes(uint32[] times, uint32[] values) public onlyOwner {
        require(times.length == values.length);
        for (uint i = 0; i + 1 < times.length; i++) {
            require(times[i] < times[i+1]);
        }

        BONUS_TIMES = times;
        BONUS_TIMES_VALUES = values;
    }

    



    function bonusesForAmountsCount() public constant returns(uint) {
        return BONUS_AMOUNTS.length;
    }

    


    function setBonusesForAmounts(uint32[] amounts, uint32[] values) public onlyOwner {
        require(amounts.length == values.length);
        for (uint i = 0; i + 1 < amounts.length; i++) {
            require(amounts[i] > amounts[i+1]);
        }

        BONUS_AMOUNTS = amounts;
        BONUS_AMOUNTS_VALUES = values;
    }

    



    function buyTokens(address beneficiary) public payable {
        
        uint256 usdValue = msg.value.mul(rate).mul(tokenPriceInCents).div(100).div(1 ether); 
        
        
        uint256 bonus = computeBonus(usdValue);

        
        uint256 oldRate = rate;
        rate = rate.mul(BONUS_COEFF.add(bonus)).div(BONUS_COEFF);
        super.buyTokens(beneficiary);
        rate = oldRate;
    }

    




    function computeBonus(uint256 usdValue) public constant returns(uint256) {
        return computeAmountBonus(usdValue).add(computeTimeBonus());
    }

    



    function computeTimeBonus() public constant returns(uint256) {
        require(now >= startTime);

        for (uint i = 0; i < BONUS_TIMES.length; i++) {
            if (now.sub(startTime) <= BONUS_TIMES[i]) {
                return BONUS_TIMES_VALUES[i];
            }
        }

        return 0;
    }

    



    function computeAmountBonus(uint256 usdValue) public constant returns(uint256) {
        for (uint i = 0; i < BONUS_AMOUNTS.length; i++) {
            if (usdValue >= BONUS_AMOUNTS[i]) {
                return BONUS_AMOUNTS_VALUES[i];
            }
        }

        return 0;
    }

}







