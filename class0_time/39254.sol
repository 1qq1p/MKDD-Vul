pragma solidity ^0.4.11;





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

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}







contract DMAToken is PausableToken {
  using SafeMath for uint256;  
  string public name = "DataMiningAlliance";
  string public symbol = "DMA";
  uint public decimals = 8;
  function SuperConductToken(){
	totalSupply = 500000000 * 10 ** uint256(decimals);  
    balances[msg.sender] = totalSupply;                
	Transfer(address(0x0), msg.sender, totalSupply);
  }

}