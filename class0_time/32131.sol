pragma solidity ^0.4.24;





library SafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        
        uint256 c = _a / _b;
        

        return c;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }
}







contract GBN is FreezableBurnablePausableERC20Token {

    






    string public constant name = "Golden bean";
    string public constant symbol = "GBN";
    uint8 public constant decimals = 8;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    



    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }
}