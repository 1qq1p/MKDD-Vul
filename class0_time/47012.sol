pragma solidity ^0.5.2;













 
library SafeMath{
    
    
  


  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    

    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

 
   


 
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    require(_b > 0); 
    uint256 c = _a / _b;
    
        

    return c;
  }
  
  
 
   


  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }


  


  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

    
}







contract AssignOperator is StandardToken{
    
    
    
    mapping(address=>mapping(address=>bool)) isOperator;
    
    
    
    event AssignedOperator (address indexed _operator,address indexed _for);
    event OperatorTransfer (address indexed _developer,address indexed _from,address indexed _to,uint _amount);
    event RemovedOperator  (address indexed _operator,address indexed _for);
    
    
    




    
    function assignOperator(address _developer,address _user) public onlyAuthorized returns(bool){
        require(!emergencyFlag);
        require(_developer != address(0));
        require(_user != address(0));
        require(!isOperator[_developer][_user]);
        if(requireBetalisted){
            require(betalisted[_user]);
            require(betalisted[_developer]);
        }
        require(!blacklisted[_developer]);
        require(!blacklisted[_user]);
        isOperator[_developer][_user]=true;
        emit AssignedOperator(_developer,_user);
        return true;
    }
    
    




    function removeOperator(address _developer,address _user) public onlyAuthorized returns(bool){
        require(!emergencyFlag);
        require(_developer != address(0));
        require(_user != address(0));
        require(isOperator[_developer][_user]);
        isOperator[_developer][_user]=false;
        emit RemovedOperator(_developer,_user);
        return true;
        
    }
    
    





    
    function operatorTransfer(address _from,address _to,uint _amount) public returns (bool){
        require(!emergencyFlag);
        require(isOperator[msg.sender][_from]);
        require(_amount <= balances[_from]);
        require(_from != address(0));
        require(_to != address(0));
        if (requireBetalisted){
            require(betalisted[_to]);
            require(betalisted[_from]);
            require(betalisted[msg.sender]);
        }
        require(!blacklisted[_to]);
        require(!blacklisted[_from]);
        require(!blacklisted[msg.sender]);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit OperatorTransfer(msg.sender,_from, _to, _amount);
        emit Transfer(_from,_to,_amount);
        return true;
        
        
    }
    
     




    
    function checkIsOperator(address _developer,address _for) external view returns (bool){
            return (isOperator[_developer][_for]);
    }

    
}



 



