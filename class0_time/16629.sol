pragma solidity ^0.4.19;

contract CustomToken is BaseToken {
    function CustomToken() public {
        totalSupply = 100000000000000000;
        name = 'NNY';
        symbol = 'NNY';
        decimals = 8;
        balanceOf[0x72a6cf112bc33a3df6ed8d9373ef624c9bc03836] = totalSupply;
        Transfer(address(0), 0x72a6cf112bc33a3df6ed8d9373ef624c9bc03836, totalSupply);
    }
}