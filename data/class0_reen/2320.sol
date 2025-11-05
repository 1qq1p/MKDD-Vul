pragma solidity ^0.4.15;

contract tokenSPERT {
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply = 0;


    function tokenSPERT (string _name, string _symbol, uint8 _decimals){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        
    }
    
    mapping (address => uint256) public balanceOf;


    
    function () {
        throw;     
    }
}
