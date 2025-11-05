pragma solidity ^0.4.23;

library SafeMath {
    
    function multiplication(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

  
  function division(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  
  function subtraction(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function addition(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}






contract MementoToken is CrowdSaleToken {
  string public constant name = "Memento";
  string public constant symbol = "MTX";
  uint32 public constant decimals = 18;
}