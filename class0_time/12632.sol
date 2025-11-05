pragma solidity ^0.4.11;






library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}







contract StakeStandard {
    uint256 public stakeStartTime;
    uint256 public stakeMinAge;
    uint256 public stakeMaxAge;
    function mine() returns (bool);
    function coinAge() constant returns (uint256);
    function annualInterest() constant returns (uint256);
    event Mine(address indexed _address, uint _reward);
}

