pragma solidity ^0.4.24;






library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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

interface token {
    function mint(address _to, uint256 _amount) public returns (bool);     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function transferOwnership(address newOwner) public;
    
}






contract Crowdsale {
    using SafeMath for uint256;

    
    token public tokenReward;

    
    uint256 public startTime;
    uint256 public endTime;

    
    address public wallet;

    
    uint256 public rate;

    
    uint256 public weiRaised;

    






    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, address _token) public {
        
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != address(0));

        
        tokenReward = token(_token);
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
    }

    
    
    
    
    

    
    
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }


}






