pragma solidity ^0.4.21;




library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    assert(a == b * c + a % b); 
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}







contract FactsToken is PausableToken, MintableToken {
  using SafeMath for uint256;

  string public name = "F4Token";
  string public symbol = "FFFF";
  uint public decimals = 18;

  


  function mintTimelocked(address _to, uint256 _amount, uint256 _releaseTime) public
    onlyOwner canMint returns (TokenTimelock) {

    TokenTimelock timelock = new TokenTimelock(this, _to, _releaseTime);
    mint(timelock, _amount);

    return timelock;
  }

  mapping (address => string) public  keys;
  event LogRegister (address user, string key);
  
  
  
  function register(string key) public {
      assert(bytes(key).length <= 64);
      keys[msg.sender] = key;
      emit LogRegister(msg.sender, key);
    }
}