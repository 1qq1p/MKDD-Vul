pragma solidity >=0.5.0 <0.6.0;





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}







contract ATD is Ownable, Pausable, SignerRole, DistributionConfigurable {
  using SafeMath for uint256;

  



  ERC20Detailed public token;

  



  constructor(
    ERC20Detailed _token
  ) public {
    token = _token;
  }

  



  event Distributed(
    uint256 indexed date,
    address indexed lockedWallet,
    address indexed unlockWallet,
    uint256 ratioDTV,
    uint256 ratioDecimals,
    uint256 dailyTradedVolume,
    uint256 amount
  );

  event TotalDistributed(
    uint256 indexed date,
    uint256 dailyTradedVolume,
    uint256 amount
  );

  



  function distribute(
    uint256 dailyTradedVolume
  ) public whenNotPaused onlySigner {
    require(
      dailyTradedVolume.div(10 ** uint256(token.decimals())) > 0,
      "dailyTradedVolume is not in token unit"
    );
    uint256 total = 0;
    for (uint256 i = 0; i < distributionConfigs.length; i++) {
      DistributionConfig storage dc = distributionConfigs[i];
      uint256 amount = dailyTradedVolume.mul(dc.ratioDTV).div(10 ** dc.ratioDecimals);
      token.transferFrom(dc.lockedWallet, dc.unlockWallet, amount);
      total = total.add(amount);
      emit Distributed(
        now,
        dc.lockedWallet,
        dc.unlockWallet,
        dc.ratioDTV,
        dc.ratioDecimals,
        dailyTradedVolume,
        amount
      );
    }
    emit TotalDistributed(now, dailyTradedVolume, total);
  }

  function destroy() public onlyOwner {
    selfdestruct(msg.sender);
  }

  function removePauser(address account) public onlyOwner {
    _removePauser(account);
  }

  function removeSigner(address account) public onlyOwner {
    _removeSigner(account);
  }

}