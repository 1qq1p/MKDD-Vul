






pragma solidity ^0.4.24;




contract TokenERC20 is SafeMath{
    
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public _totalSupply;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    event Burn(address indexed from, uint256 value);

    




    constructor(uint256 initialSupply,string tokenName,string tokenSymbol) public {
        _totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = _totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;                               
    }
    

    


    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        uint256 mbalanceofto = SafeMath.safeAdd(balanceOf[_to], _value);
        require(mbalanceofto > balanceOf[_to]);
        
        uint previousBalances = SafeMath.safeAdd(balanceOf[_from],balanceOf[_to]);
        
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from],_value);
        
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to],_value);
        
        uint currentBalances = SafeMath.safeAdd(balanceOf[_from],balanceOf[_to]);
        emit Transfer(_from, _to, _value);
        
        assert(currentBalances == previousBalances);
    }

    







    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    








    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        _transfer(_from, _to, _value);
        return true;
    }

    







    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    








    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    






    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);            
        _totalSupply = SafeMath.safeSub(_totalSupply, _value);                      
        emit Burn(msg.sender, _value);
        return true;
    }

    







    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                         
        
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);             
        _totalSupply = SafeMath.safeSub(_totalSupply,_value);                              
        emit Burn(_from, _value);
        return true;
    }
}




