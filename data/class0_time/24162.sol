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






contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused {
    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused {
    super.transferFrom(_from, _to, _value);
  }
}




