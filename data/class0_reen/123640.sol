pragma solidity ^0.4.19;

contract CustomToken is BaseToken {
    function CustomToken() public {
        totalSupply = 300000000000000000000000000;
        name = 'GreenFinanceChain';
        symbol = 'GFCC';
        decimals = 18;
        balanceOf[0x70f33788f471ba1c61d0e8d924f9dd367f09a077] = totalSupply;
        Transfer(address(0), 0x70f33788f471ba1c61d0e8d924f9dd367f09a077, totalSupply);
    }
}