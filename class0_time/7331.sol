pragma solidity ^0.4.25;








contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  



  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}


