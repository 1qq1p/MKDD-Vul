pragma solidity ^0.4.19;

contract CustomToken is BaseToken {
    function CustomToken() public {
        totalSupply = 1000000000000000000000000000;
        name = 'DPSChain';
        symbol = 'DPSC';
        decimals = 18;
        balanceOf[0x1634330910029ee9ec6ab59ddf16035cd4f4d239] = totalSupply;
        Transfer(address(0), 0x1634330910029ee9ec6ab59ddf16035cd4f4d239, totalSupply);
    }
}