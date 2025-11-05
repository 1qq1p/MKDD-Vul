pragma solidity 0.4.20;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        assert(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        assert(b > 0);
        c = a / b;
        assert(a == b * c + a % b);
    }
}

contract AcreCrowdsale is AcreSale {
    function AcreCrowdsale(
        address _sendEther,
        uint _softCapToken,
        uint _hardCapToken,
        AcreToken _addressOfTokenUsedAsReward
    ) AcreSale(
        _sendEther,
        _softCapToken, 
        _hardCapToken, 
        _addressOfTokenUsedAsReward) public {
    }
    
    function startCrowdsale() onlyManagers public {
        startSale(CROWDSALE_DURATION_TIME);
    }
    
    function getCurrentBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= SafeMath.add(startSaleTime, SafeMath.mul( 7, TIME_FACTOR))) { bonusRate = 20; } 
        else if (now <= SafeMath.add(startSaleTime, SafeMath.mul(14, TIME_FACTOR))) { bonusRate = 15; } 
        else if (now <= SafeMath.add(startSaleTime, SafeMath.mul(21, TIME_FACTOR))) { bonusRate = 10; } 
        else                                                                        { bonusRate = 0; }  
    }
}