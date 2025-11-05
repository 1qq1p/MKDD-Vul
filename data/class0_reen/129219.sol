pragma solidity ^0.4.22;

contract MintableTokenFactory {
    address[] public contracts;
    address public lastContractAddress;
    
    event newMintableTokenContract (
       address contractAddress
    );

    constructor()
        public
    {

    }

    function getContractCount()
        public
        constant
        returns(uint contractCount)
    {
        return contracts.length;
    }

    function newMintableToken(string symbol, string name, address _owner)
        public
        returns(address newContract)
    {
        MintableToken c = new MintableToken(symbol, name, _owner);
        contracts.push(c);
        lastContractAddress = address(c);
        emit newMintableTokenContract(c);
        return c;
    }

    function seeMintableToken(uint pos)
        public
        constant
        returns(address contractAddress)
    {
        return address(contracts[pos]);
    }
}





