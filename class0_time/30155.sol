pragma solidity ^0.4.13;

contract Lamden is MintingERC20 {


    uint8 public decimals = 18;

    string public tokenName = "Lamden Tau";

    string public tokenSymbol = "TAU";

    uint256 public  maxSupply = 500 * 10 ** 6 * uint(10) ** decimals; 

    
    bool public transferFrozen = true;

    function Lamden(
    uint256 initialSupply,
    bool _locked
    ) MintingERC20(initialSupply, maxSupply, tokenName, decimals, tokenSymbol, false, _locked) {
        standard = 'Lamden 0.1';
    }

    function setLocked(bool _locked) onlyOwner {
        locked = _locked;
    }

    
    function freezing(bool _transferFrozen) onlyOwner {
        transferFrozen = _transferFrozen;
    }

    
    

    function transfer(address _to, uint _value) returns (bool) {
        require(!transferFrozen);
        return super.transfer(_to, _value);

    }

    
    function approve(address, uint) returns (bool success)  {
        require(false);
        return false;
        
    }

    function approveAndCall(address, uint256, bytes) returns (bool success) {
        require(false);
        return false;
    }

    function transferFrom(address, address, uint)  returns (bool success) {
        require(false);
        return false;
        
    }
}