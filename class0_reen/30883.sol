pragma solidity ^0.4.2;

contract SOCToken {
    
    mapping (address => uint256) public balanceOf;

    
    function SOCToken(
        uint256 initialSupply
        ) {
        balanceOf[msg.sender] = initialSupply;              
    }

    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        balanceOf[msg.sender] -= _value;                     
        balanceOf[_to] += _value;                            
    }
}

