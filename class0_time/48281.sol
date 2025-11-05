pragma solidity ^0.4.18;

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

contract RewardDistributable {
    event TokensRewarded(address indexed player, address rewardToken, uint rewards, address requester, uint gameId, uint block);
    event ReferralRewarded(address indexed referrer, address indexed player, address rewardToken, uint rewards, uint gameId, uint block);
    event ReferralRegistered(address indexed player, address indexed referrer);

    
    function transferRewards(address player, uint entryAmount, uint gameId) public;

    
    function getTotalTokens(address tokenAddress) public constant returns(uint);

    
    function getRewardTokenCount() public constant returns(uint);

    
    function getTotalApprovers() public constant returns(uint);

    
    function getRewardRate(address player, address tokenAddress) public constant returns(uint);

    
    
    function addRequester(address requester) public;

    
    
    function removeRequester(address requester) public;

    
    
    function addApprover(address approver) public;

    
    
    function removeApprover(address approver) public;

    
    function updateRewardRate(address tokenAddress, uint newRewardRate) public;

    
    function addRewardToken(address tokenAddress, uint newRewardRate) public;

    
    function removeRewardToken(address tokenAddress) public;

    
    function updateReferralBonusRate(uint newReferralBonusRate) public;

    
    
    
    function registerReferral(address player, address referrer) public;

    
    function destroyRewards() public;
}
