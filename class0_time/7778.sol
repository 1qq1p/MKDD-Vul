pragma solidity ^0.4.11;






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








contract GlobCoinToken is MintableToken {
  using SafeMath for uint256;
  string public constant name = "GlobCoin Crypto Platform";
  string public constant symbol = "GCP";
  uint8 public constant decimals = 18;

  modifier onlyMintingFinished() {
    require(mintingFinished == true);
    _;
  }
  
  
  
  function approve(address _spender, uint256 _value) public onlyMintingFinished returns (bool) {
      return super.approve(_spender, _value);
  }

  
  
  
  function transfer(address _to, uint256 _value) public onlyMintingFinished returns (bool) {
      return super.transfer(_to, _value);
  }

  
  
  
  
  function transferFrom(address _from, address _to, uint256 _value) public onlyMintingFinished returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

}