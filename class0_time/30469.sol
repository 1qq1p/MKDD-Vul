pragma solidity ^0.4.22;





library SafeMath {
  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
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






contract BCBToken is ERC20Token, Ownable {
  uint256 constant public BCB_UNIT = 10 ** 18;

  string public constant name = "BCBToken";
  string public constant symbol = "BCB";
  uint32 public constant decimals = 18;

  uint256 public totalSupply = 120000000 * BCB_UNIT;
  uint256 public lockedAllocation = 53500000 * BCB_UNIT;
  uint256 public totalAllocated = 0;
  address public allocationAddress;

  uint256 public lockEndTime;

  constructor(address _allocationAddress) public {
    
    balanceOf[owner] = totalSupply - lockedAllocation;
    allocationAddress = _allocationAddress;

    
    lockEndTime = now + 12 * 30 days;
  }

  




  function releaseLockedTokens() public onlyOwner {
    require(now > lockEndTime);
    require(totalAllocated < lockedAllocation);

    totalAllocated = lockedAllocation;
    balanceOf[allocationAddress] = balanceOf[allocationAddress].add(lockedAllocation);

    emit Transfer(0x0, allocationAddress, lockedAllocation);
  }

  





  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool) {
    if (approve(_spender, _value)) {
      ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
      return true;
    }
  }
}