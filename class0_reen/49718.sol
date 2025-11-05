pragma solidity ^0.4.16;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract OPTCToken is PausableToken {
    





    string public name = "OPTICAL NETWORK";
    string public symbol = "OPTC";
    string public version = '2.0.0';
    uint8 public decimals = 18;

    


    function OPTCToken() {
      totalSupply = 36 * 10000 * 10000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }

    function () external payable {
        
        revert();
    }
}