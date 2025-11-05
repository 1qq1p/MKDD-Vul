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






contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  


  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size.add(4)) {
       revert();
     }
     _;
  }

  




  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    require(_to != 0x0);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

  




  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}




