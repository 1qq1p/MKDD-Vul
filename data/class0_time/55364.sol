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






 
contract Configurable {
    uint256 public constant cap = 1000000*10**18;
    uint256 public constant basePrice = 100*10**18; 
    uint256 public tokensSold = 0;
    
    uint256 public constant tokenReserve = 1000000*10**18;
    uint256 public remainingTokens = 0;
}




