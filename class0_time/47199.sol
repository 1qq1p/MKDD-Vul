pragma solidity ^0.4.22;












 
 
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);  
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


contract BodyOneToken is StandardToken {
    string public name = "BodyOne";
    string public symbol = "BODY";
    uint public decimals = 18;

    







    function BodyOneToken(address _owner) {
        owner = _owner;
        totalSupply = 100 * 10 ** 26;
        balances[owner] = totalSupply;
    }

    



    
    
    function () public payable {
        revert();
    }
}