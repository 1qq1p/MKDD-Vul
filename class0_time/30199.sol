pragma solidity ^0.4.11;

contract SolarEclipseToken is StandardToken {
    uint8 public decimals = 18;
    string public name = 'Solar Eclipse Token';
    address owner;
    string public symbol = 'SET';

    uint startTime = 1503330410; 
    uint endTime = 1503349461; 

    uint metersInAstronomicalUnit = 149597870700;
    uint milesInAstronomicalUnit = 92955807;
    uint speedOfLightInMetersPerSecond = 299792458;

    uint public totalSupplyCap = metersInAstronomicalUnit * 1 ether;
    uint public tokensPerETH = milesInAstronomicalUnit;

    uint public ownerTokens = speedOfLightInMetersPerSecond * 10 ether;

    function ownerWithdraw() {
        if (msg.sender != owner) revert(); 

        owner.transfer(this.balance); 
    }

    function () payable {
        if (now < startTime) revert(); 
        if (now > endTime) revert(); 
        if (totalSupply >= totalSupplyCap) revert(); 

        uint tokensIssued = msg.value * tokensPerETH;

        if (totalSupply + tokensIssued > totalSupplyCap) {
            tokensIssued = totalSupplyCap - totalSupply; 
        }

        totalSupply += tokensIssued;
        balances[msg.sender] += tokensIssued; 
    }

    function SolarEclipseToken() {
        owner = msg.sender;
        totalSupply = ownerTokens;
        balances[owner] = ownerTokens;
    }
}