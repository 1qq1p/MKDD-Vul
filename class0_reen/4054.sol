pragma solidity ^0.4.25;






contract BolttCoin is ReleasableToken, MintableToken, UpgradeableToken {

  
  event UpdatedTokenInformation(string newName, string newSymbol);

  
  event WavesTransfer(address indexed _from, string wavesAddress, uint256 amount);

  string public name;

  string public symbol;

  uint public decimals;

  address public wavesReserve;

  








  constructor(string memory _name, string memory _symbol, uint _initialSupply, uint _decimals, address _wavesReserve)
    UpgradeableToken(msg.sender) public {
    require(_wavesReserve != address(0));

    owner = msg.sender;

    name = _name;
    symbol = _symbol;

    totalSupply_ = _initialSupply;

    decimals = _decimals;

    wavesReserve = _wavesReserve;

    
    balances[owner] = totalSupply_;

    if(totalSupply_ > 0) {
      emit Minted(owner, totalSupply_);
      mintingFinished = true;
    }
  }

  


  function releaseTokenTransfer() public onlyReleaseAgent {
    super.releaseTokenTransfer();
  }

  


  function canUpgrade() public view returns(bool) {
    return released && super.canUpgrade();
  }

  


  function getTokenChainType() public pure returns(string) {
    return 'erc20-waves-dual';
  }

  


  function setTokenInformation(string memory _name, string memory _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;

    emit UpdatedTokenInformation(name, symbol);
  }

  function moveToWaves(string memory wavesAddress, uint256 amount) public {
      require(transfer(wavesReserve, amount));
      emit WavesTransfer(msg.sender, wavesAddress, amount);
  }

}