pragma solidity ^0.4.19;

contract CustomToken is BaseToken, ICOToken {
    function CustomToken() public {
        totalSupply = 210000000000000000000000000;
        balanceOf[0xf588d792fa8a634162760482a7b61dd1ab99b1f1] = totalSupply;
        name = 'ETGcoin';
        symbol = 'ETG';
        decimals = 18;
        icoRatio = 88888;
        icoEndtime = 1519812000;
        icoSender = 0xf588d792fa8a634162760482a7b61dd1ab99b1f1;
        icoHolder = 0xf043ae16a61ece2107eb2ba48dcc7ad1c8f9f2dc;
    }
}