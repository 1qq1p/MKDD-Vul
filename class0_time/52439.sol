pragma solidity 0.4.18;

contract SafeMath {

  function safeMul(uint a, uint b) pure internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function safeSub(uint a, uint b) pure internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function safeAdd(uint a, uint b) pure internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
  function safeNumDigits(uint number) pure internal returns (uint8) {
    uint8 digits = 0;
    while (number != 0) {
        number /= 10;
        digits++;
    }
    return digits;
}

  
  
  
  modifier onlyPayloadSize(uint numWords) {
     assert(msg.data.length >= numWords * 32 + 4);
     _;
  }

}
