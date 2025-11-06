pragma solidity 0.4.25;









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

}




contract Asset is ERC20Token {
    string public name = 'XYZBuys';
    uint8 public decimals = 18;
    string public symbol = 'XYZB';
    string public version = '1';

    constructor() public {
        totalSupply = 1000000000 * (10**uint256(decimals)); 
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
    }

    



    function claimTokens(token _address, address _to) onlyAdmin(2) public{
        require(_to != address(0));
        uint256 remainder = _address.balanceOf(address(this)); 
        _address.transfer(_to,remainder); 
    }

    


    function() external {
        revert();
    }

}