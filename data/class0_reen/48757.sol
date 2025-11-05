pragma solidity ^0.4.11;







library Math {
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
}





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






contract ABCPresale is Ownable {
  using SafeMath for uint256;

  ABCToken public token;

  uint256 public startBlock;
  uint256 public endBlock;
  bool public presaleClosedManually = false;
  bool public isFinalized = false;
  address public founders;
  address public developer;
  uint256 public weiRaised;
  uint public rate = 181818; 

  uint public hardcap = 5550 ether; 
  uint public softcap = 5500 ether; 
  uint founders_abc = 2500 ether; 
  uint developer_abc = 15 ether; 

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Finalized();
  event ClosedManually();

  function ABCPresale(uint256 _startBlock, uint256 _endBlock, address _founders, address _developer) {
    require(_startBlock >= block.number);
    require(_endBlock >= _startBlock);

    token = createTokenContract();
    startBlock = _startBlock;
    endBlock = _endBlock;
    founders = _founders;
    developer = _developer;
  }

  function createTokenContract() internal returns (ABCToken) {
    return new ABCToken();
  }

  function () payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    uint256 tokens = weiAmount.div(100).mul(rate);

    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function forwardFunds() internal {
    founders.transfer(msg.value);
  }

  function validPurchase() internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = weiRaised.add(msg.value) <= hardcap;
    bool biggerThanLeftBound = msg.value >= 300 finney;
    bool smallerThanRightBound = msg.value <= 1000 ether;
    return withinPeriod && nonZeroPurchase && withinCap && biggerThanLeftBound && smallerThanRightBound && !presaleClosedManually && !isFinalized;
  }

  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= softcap;
    return block.number > endBlock || capReached || presaleClosedManually || isFinalized;
  }

  function changeTokenOwner(address newOwner) onlyOwner {
    token.transferOwnership(newOwner);
  }

  function closePresale() onlyOwner {
    require(!isFinalized);
    require(!presaleClosedManually);
    require(block.number > startBlock && block.number < endBlock);
    presaleClosedManually = true;
    
    finalization();
    ClosedManually();

    isFinalized = true;
  }

  function finalize() onlyOwner {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();
    
    isFinalized = true;
  }

  function finalization() internal {
    token.mint(developer, developer_abc.mul(2000));
    token.mint(founders, founders_abc.mul(2000));
  }

}