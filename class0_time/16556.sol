



pragma solidity ^0.4.23;






library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        
        
        
        if (a == 0) {
            return 0;
        }

        c = a * b;
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

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}






contract GNE is StandardToken {
    string public name = "Green New Energy";
    string public symbol = "GNE";
    uint8 public decimals = 18;
    uint256 public INITIAL_SUPPLY = 1000000000 * 10 ** uint256(decimals);

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}