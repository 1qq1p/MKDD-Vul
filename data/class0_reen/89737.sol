pragma solidity ^0.4.16;











library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
    }

}





contract AssetTM3 is ERC20Token {
    string public name = 'Temple3';
    uint256 public decimals = 18;
    string public symbol = 'TM3';
    string public version = '1';
    
    


    function AssetTM3(uint256 _initialSupply) public {
        totalSupply = _initialSupply; 
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = totalSupply.div(1000);
        balances[msg.sender] = totalSupply.sub(balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6]);
        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, balances[msg.sender]);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6]);        
    }
    
    



    function() public {
        revert();
    }

}