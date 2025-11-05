pragma solidity 0.4.24;



contract DipToken is PausableToken, MintableToken {

  string public constant name = "Decentralized Insurance Protocol";
  string public constant symbol = "DIP";
  uint256 public constant decimals = 18;
  uint256 public constant MAXIMUM_SUPPLY = 10**9 * 10**18; 

  DipTgeInterface public DipTokensale;

  constructor() public {
    DipTokensale = DipTgeInterface(owner);
  }

  modifier shouldNotBeLockedIn(address _contributor) {
    
    
    require(DipTokensale.tokenIsLocked(_contributor) == false);
    _;
  }

  





  function mint(address _to, uint256 _amount) public returns (bool) {
    if (totalSupply.add(_amount) > MAXIMUM_SUPPLY) {
      return false;
    }

    return super.mint(_to, _amount);
  }

  




  function salvageTokens(ERC20Basic _token, address _to) onlyOwner public {
    _token.transfer(_to, _token.balanceOf(this));
  }

  function transferFrom(address _from, address _to, uint256 _value) shouldNotBeLockedIn(_from) public returns (bool) {
      return super.transferFrom(_from, _to, _value);
  }

  function transfer(address to, uint256 value) shouldNotBeLockedIn(msg.sender) public returns (bool) {
      return super.transfer(to, value);
  }
}










