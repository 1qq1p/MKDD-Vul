


pragma solidity ^0.4.21;








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






contract CappedFundraiser is BasicFundraiser {
    
    uint256 public hardCap;

    




    function initializeCappedFundraiser(uint256 _hardCap) internal {
        require(_hardCap > 0);

        hardCap = _hardCap;
    }

    




    function validateTransaction() internal view {
        super.validateTransaction();
        require(totalRaised < hardCap);
    }

    





    function hasEnded() public view returns (bool) {
        return (super.hasEnded() || totalRaised >= hardCap);
    }
}







