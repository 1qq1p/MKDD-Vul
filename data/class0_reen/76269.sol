pragma solidity ^0.4.25;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
 
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

}

contract CustomToken is PausableToken {

    string public name;
    string public symbol;
    uint8 public decimals ;
   
    
    
    string  public constant tokenName = "ZBT.COM Token";
    string  public constant tokenSymbol = "ZBT";
    uint8   public constant tokenDecimals = 6;
    
    uint256 public constant initTokenSUPPLY      = 5000000000 * (10 ** uint256(tokenDecimals));
             
                                        
    constructor () public {

        name = tokenName;

        symbol = tokenSymbol;

        decimals = tokenDecimals;

        totalSupply = initTokenSUPPLY;    
                
        balances[msg.sender] = totalSupply;   

    }    

}