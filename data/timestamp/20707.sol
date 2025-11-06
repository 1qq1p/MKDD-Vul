

pragma solidity ^0.4.8;

contract CMCC is StandardToken {

    
    





    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = "P0.1";       
    function CMCC() {
        balances[msg.sender] = 99846700000000;               
        totalSupply = 99846700000000;                        
        name = "Canadian maple crypto coin";                                   
        decimals = 6;                            
        symbol = "CMCC";                               
    }
}