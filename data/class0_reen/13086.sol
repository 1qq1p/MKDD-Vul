pragma solidity ^0.4.23;



contract TokenDistor is Ownerable, SafeMath {
  using SafeERC20 for ERC20Basic;

  ERC20Basic token;

  constructor() public {
  }

  function setToken(address _token) public onlyOwner {
    require(_token != 0x0);
    token = ERC20Basic(_token);
  }

  function airdrop(address[] _tos, uint256[] _amts) public onlyOwner {
    require(_tos.length == _amts.length);

    uint256 totalSendingAmt = 0;

    for(uint i=0; i<_tos.length; i++) {
      


      totalSendingAmt = add(totalSendingAmt, _amts[i]);
    }

    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance >= totalSendingAmt);

    for(i=0; i<_tos.length; i++) {
      if(_tos[i] != 0x0 && _amts[i] > 0) {
        token.safeTransfer(_tos[i], _amts[i]);
      }
    }
  }

  function distStaticAmount(address[] _tos, uint256 _amt) public onlyOwner {
    require(_tos.length > 0);
    require(_amt > 0);

    uint256 totalSendingAmt = mul(_amt, _tos.length);
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance >= totalSendingAmt);

    for(uint i=0; i<_tos.length; i++) {
      if(_tos[i] != 0x0) {
        token.safeTransfer(_tos[i], _amt);
      }
    }
  }

  function claimTokens(address _to) public onlyOwner {
    require(_to != 0x0);
    
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance > 0);

    token.safeTransfer(_to, tokenBalance);
  }
}