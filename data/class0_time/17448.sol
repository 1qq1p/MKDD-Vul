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

contract RewardApprover is Ownable {

    FullERC20 public token;
    RewardDistributable internal rewardDistributor;

    
    
    function approveTokenTransfers() internal {
        if (rewardDistributor == address(0) || token == address(0)) {
            return;
        }

        uint balance = token.balanceOf(this);
        token.approve(rewardDistributor, balance);
    }
    
    
    function updateRewardDistributor(address newRewardDistributor) public onlyOwner {
        rewardDistributor = RewardDistributable(newRewardDistributor);
    }
}
