pragma solidity ^0.4.18;









interface IMultiOwned {

    




    function isOwner(address _account) public view returns (bool);


    




    function getOwnerCount() public view returns (uint);


    





    function getOwnerAt(uint _index) public view returns (address);


     




    function addOwner(address _account) public;


    




    function removeOwner(address _account) public;
}










contract Token is IToken, InputValidator {

    
    string public standard = "Token 0.3.1";
    string public name;        
    string public symbol;
    uint8 public decimals;

    
    uint internal totalTokenSupply;

    
    mapping (address => uint) internal balances;

    
    mapping (address => mapping (address => uint)) internal allowed;


    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    






    function Token(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[msg.sender] = 0;
        totalTokenSupply = 0;
    }


    




    function totalSupply() public view returns (uint) {
        return totalTokenSupply;
    }


    





    function balanceOf(address _owner) public view returns (uint) {
        return balances[_owner];
    }


    






    function transfer(address _to, uint _value) public safe_arguments(2) returns (bool) {

        
        require(balances[msg.sender] >= _value);   

        
        require(balances[_to] + _value >= balances[_to]);

        
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        
        Transfer(msg.sender, _to, _value);
        return true;
    }


    







    function transferFrom(address _from, address _to, uint _value) public safe_arguments(3) returns (bool) {

        
        require(balances[_from] >= _value);

        
        require(balances[_to] + _value >= balances[_to]);

        
        require(_value <= allowed[_from][msg.sender]);

        
        balances[_to] += _value;
        balances[_from] -= _value;

        
        allowed[_from][msg.sender] -= _value;

        
        Transfer(_from, _to, _value);
        return true;
    }


    






    function approve(address _spender, uint _value) public safe_arguments(2) returns (bool) {

        
        allowed[msg.sender][_spender] = _value;

        
        Approval(msg.sender, _spender, _value);
        return true;
    }


    






    function allowance(address _owner, address _spender) public view returns (uint) {
      return allowed[_owner][_spender];
    }
}














interface IManagedToken { 

    




    function isLocked() public view returns (bool);


    




    function lock() public returns (bool);


    




    function unlock() public returns (bool);


    






    function issue(address _to, uint _value) public returns (bool);


    






    function burn(address _from, uint _value) public returns (bool);
}












