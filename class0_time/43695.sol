pragma solidity ^0.4.23;




 library SafeMath {
   


   function mul(uint256 a, uint256 b) internal returns (uint256 c) {
     if (a == 0) {
       return 0;
     }
     c = a * b;
     assert(c / a == b);
     return c;
   }

   


   function div(uint256 a, uint256 b) internal returns (uint256) {
     
     
     
     return a / b;
   }

   


   function sub(uint256 a, uint256 b) internal returns (uint256) {
     assert(b <= a);
     return a - b;
   }

   


   function add(uint256 a, uint256 b) internal returns (uint256 c) {
     c = a + b;
     assert(c >= a && c >= b);
     return c;
   }

   function assert(bool assertion) internal {
     if (!assertion) {
       revert();
     }
   }
 }






contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  





  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    require(_to != 0x0);
    uint _allowance = allowed[_from][msg.sender];

    
    

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
  }

  




  function approve(address _spender, uint _value) {

    
    
    
    
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  





  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}





