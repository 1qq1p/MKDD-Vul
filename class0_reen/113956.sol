pragma solidity ^0.4.19;

contract CustomToken is BaseToken {
    function CustomToken() public {
        totalSupply = 84000000000000000000000000;
        name = 'ANC';
        symbol = 'ANC';
        decimals = 18;
        balanceOf[0x5ebc4B61A0E0187d9a72Da21bfb8b45F519cb530] = totalSupply;
        Transfer(address(0), 0x5ebc4B61A0E0187d9a72Da21bfb8b45F519cb530, totalSupply);
    }
}