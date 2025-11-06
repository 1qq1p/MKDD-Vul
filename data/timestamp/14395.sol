pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract MEXCFinalSale is Ownable, Destructible {
  using SafeMath for uint256;

  
  MintableToken public token;

  
  address public wallet = address(0);

  
  uint256 public rate = 50000;

  
  uint256 public weiRaised = 0;

  
  bool closed = false;

  






  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function MEXCFinalSale(MintableToken _contract, address _wallet) public {
    token = _contract;
    wallet = _wallet;
  }

  function setTokenContract(MintableToken _contract) public onlyOwner {
    token = _contract;
  }

  function setTokenOwner (address _newOwner) public onlyOwner {
    token.transferOwnership(_newOwner);
  }

  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

  function setRate(uint256 _rate) public onlyOwner {
    rate = _rate;
  }

  function closeSale() public onlyOwner {
    closed = true;
  }

  function openSale() public onlyOwner {
    closed = false;
  }

  
  function () external payable {
    buyTokens(msg.sender);
  }

  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    
    uint256 tokens = weiAmount.mul(rate);

    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal view returns (bool) {
    return msg.value != 0 && !closed;
  }
  
  function mintToken(address _recipient, uint256 _tokens) public onlyOwner {
    
    token.mint(_recipient, _tokens);
  }

  
  function hasEnded() public view returns (bool) {
    return closed;
  }

}