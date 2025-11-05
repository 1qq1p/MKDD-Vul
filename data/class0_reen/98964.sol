pragma solidity ^0.4.15;






library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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







library Math {
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







contract AlvalorToken is PausableToken {

  using SafeMath for uint256;

  
  string public constant name = "Alvalor";
  string public constant symbol = "TVAL";
  uint8 public constant decimals = 12;

  
  bool public frozen = false;

  
  
  uint256 public constant maxSupply = 18446744073709551615;
  uint256 public constant dropSupply = 3689348814741910323;

  
  uint256 public claimedSupply = 0;

  
  mapping(address => uint256) private claims;

  
  event Freeze();
  event Drop(address indexed receiver, uint256 value);
  event Mint(address indexed receiver, uint256 value);
  event Claim(address indexed receiver, uint256 value);
  event Burn(address indexed receiver, uint256 value);

  
  
  modifier whenNotFrozen() {
    require(!frozen);
    _;
  }

  modifier whenFrozen() {
    require(frozen);
    _;
  }

  
  
  function AlvalorToken() public {
    claims[owner] = dropSupply;
  }

  
  
  function freeze() external onlyOwner whenNotFrozen {
    frozen = true;
    Freeze();
  }

  
  
  function mint(address _receiver, uint256 _value) onlyOwner whenNotFrozen public returns (bool) {
    require(_value > 0);
    require(_value <= maxSupply.sub(totalSupply).sub(dropSupply));
    totalSupply = totalSupply.add(_value);
    balances[_receiver] = balances[_receiver].add(_value);
    Mint(_receiver, _value);
    return true;
  }

  function claimable(address _receiver) constant public returns (uint256) {
    if (claimedSupply >= dropSupply) {
      return 0;
    }
    return claims[_receiver];
  }

  
  
  function drop(address _receiver, uint256 _value) onlyOwner whenNotFrozen public returns (bool) {
    require(claimedSupply < dropSupply);
    require(_receiver != owner);
    claims[_receiver] = _value;
    Drop(_receiver, _value);
    return true;
  }

  
  
  function claim() whenNotPaused whenFrozen public returns (bool) {
    require(claimedSupply < dropSupply);
    uint value = Math.min256(claims[msg.sender], dropSupply.sub(claimedSupply));
    claims[msg.sender] = claims[msg.sender].sub(value);
    claimedSupply = claimedSupply.add(value);
    totalSupply = totalSupply.add(value);
    balances[msg.sender] = balances[msg.sender].add(value);
    Claim(msg.sender, value);
    return true;
  }
}