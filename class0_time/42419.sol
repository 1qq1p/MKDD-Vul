pragma solidity ^0.4.8;


contract VeritaseumToken is Ownable, StandardToken {

    string public name = "Veritaseum";          
    string public symbol = "VERI";              
    uint public decimals = 18;                  

    uint public totalSupply = 100000000 ether;  

    
    function VeritaseumToken() {
        balances[msg.sender] = totalSupply;
    }
  
    

    
    
    function transferOwnership(address _newOwner) onlyOwner {
        balances[_newOwner] = balances[owner];
        balances[owner] = 0;
        Ownable.transferOwnership(_newOwner);
    }
}