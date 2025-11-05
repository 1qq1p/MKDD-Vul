







pragma solidity ^0.4.24;





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







contract OGX is PausableToken, MintableToken, BurnableToken {
  using SafeMath for uint256;

  string public name = "OGX";
  string public symbol = "OGX";
  uint public decimals = 18;

  
  uint256 public constant HARD_CAP = 224115116  * 10**uint256(decimals);  
  

  


  function mintTimelocked(address _to, uint256 _amount, uint256 _releaseTime)
    onlyOwner canMint returns (TokenTimelock) {

    TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
    mint(timelock, _amount);

    return timelock;
  }

}