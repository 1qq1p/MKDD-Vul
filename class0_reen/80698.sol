pragma solidity ^0.4.23;



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

contract LucreVesting is Ownable {
    struct Vesting {        
        uint256 amount;
        uint256 endTime;
    }
    mapping(address => Vesting) internal vestings;

    function addVesting(address _user, uint256 _amount, uint256 _endTime) public ;
    function getVestedAmount(address _user) public view returns (uint256 _amount);
    function getVestingEndTime(address _user) public view returns (uint256 _endTime);
    function vestingEnded(address _user) public view returns (bool) ;
    function endVesting(address _user) public ;
}

