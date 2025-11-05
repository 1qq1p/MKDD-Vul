pragma solidity ^0.4.24;








contract LockerVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  
  address public beneficiary;

  uint256 public start;
  uint256 public period;
  uint256 public chunks;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  









  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _period,
    uint256 _chunks,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));

    beneficiary = _beneficiary;
    revocable = _revocable;
    period = _period;
    chunks = _chunks;
    start = _start;
  }

  



  function release(ERC20Basic _token) public {
    uint256 unreleased = releasableAmount(_token);

    require(unreleased > 0);

    released[_token] = released[_token].add(unreleased);

    _token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
  }

  




  function revoke(ERC20Basic _token) public onlyOwner {
    require(revocable);
    require(!revoked[_token]);

    uint256 balance = _token.balanceOf(address(this));

    uint256 unreleased = releasableAmount(_token);
    uint256 refund = balance.sub(unreleased);

    revoked[_token] = true;

    _token.safeTransfer(owner, refund);

    emit Revoked();
  }

  



  function releasableAmount(ERC20Basic _token) public view returns (uint256) {
    return vestedAmount(_token).sub(released[_token]);
  }

  



  function vestedAmount(ERC20Basic _token) public view returns (uint256) {
    uint256 currentBalance = _token.balanceOf(address(this));
    uint256 totalBalance = currentBalance.add(released[_token]);

    require(chunks < 100);
    
    if (block.timestamp < start) {
      return 0;
    } 
    for (uint i=0; i<chunks; i++) {
      if (block.timestamp > start.add(period.mul(i)) && block.timestamp <= start.add(period.mul(i+1))) {
        
        return totalBalance.div(chunks).mul(i+1);
      } 
    }
    return 0;
  }
}





pragma solidity ^0.4.24;



