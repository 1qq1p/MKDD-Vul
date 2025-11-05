pragma solidity ^0.4.18;








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
        
        
        
        return a / b;
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





contract StormBrewCoin is StandardToken {
    
    string public name = "Storm Brew Coin";
    string public symbol = "SBC";
    string public version = "1.0";
    uint8 public decimals = 4;
    
    uint256 INITIAL_SUPPLY = 400000000e4;
    
    function StormBrewCoin() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[this] = totalSupply_;
        allowed[this][msg.sender] = totalSupply_;
        
        emit Approval(this, msg.sender, balances[this]);
    }

}