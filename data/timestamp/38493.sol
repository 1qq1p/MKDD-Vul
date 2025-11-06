pragma solidity ^0.4.16;

contract TokenPAD is owned, SafeMath {
    
    string public name = "Platform for Air Drops";
    string public symbol = "PAD";
    uint8 public decimals = 18;
    uint256 public totalSupply = 15000000000000000000000000;
    
   
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Burn(address indexed from, uint256 value);

    




    function TokenPAD(
      
    ) public {
       
         balanceOf[msg.sender] = totalSupply;                 

    }

    


    function _transfer(address _from, address _to, uint _value) internal {
         
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        require(add(balanceOf[_to],_value) > balanceOf[_to]);
        
        uint previousBalances = add(balanceOf[_from], balanceOf[_to]);
        
        balanceOf[_from] = sub(balanceOf[_from],_value);
        
        balanceOf[_to] =add(balanceOf[_to],_value);
        Transfer(_from, _to, _value);
        
        assert(add(balanceOf[_from],balanceOf[_to]) == previousBalances);
    }

    







    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
    }

    








    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] = sub(allowance[_from][msg.sender],_value);
        _transfer(_from, _to, _value);
        return true;
    }

    







    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    








    function approveAndCall(address _spender, uint256 _value, bytes _extraData) onlyOwner
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    






    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] = sub( balanceOf[msg.sender],_value);            
        totalSupply =sub(totalSupply,_value);                      
        Burn(msg.sender, _value);
        return true;
    }
}