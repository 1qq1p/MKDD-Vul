pragma solidity ^0.4.24;








library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b,"");

        return c;
    }
  
    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0,""); 
        uint256 c = a / b;
        
  
        return c;
    }
  
    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"");
        uint256 c = a - b;

        return c;
    }
  
    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"");

        return c;
    }
  
    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"");
        return a % b;
    }
}






contract EIP20Interface {
    








    
    uint256 public totalSupply;

    
    
    function balanceOf(address _owner) public view returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

