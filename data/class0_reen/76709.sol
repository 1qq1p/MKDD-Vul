pragma solidity ^0.4.18;






contract UniversalCoin is BurnableToken, Ownable {

    string constant public name = "UniversalCoin";
    string constant public symbol = "UNV";
    uint256 constant public decimals = 6;
    uint256 constant public airdropReserve = 2400000000E6; 
    uint256 constant public pool = 32000000000E6;

    function UniversalCoin(address uniFoundation) public {
        totalSupply = 40000000000E6; 
        balances[uniFoundation] = 5600000000E6; 
        balances[owner] = pool + airdropReserve; 
    }

}