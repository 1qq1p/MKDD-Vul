pragma solidity ^0.4.13;

interface ERC721Enumerable  {
    
    
    
    function totalSupply() public view returns (uint256);

    
    
    
    
    
    function tokenByIndex(uint256 _index) external view returns (uint256);

    
    
    
    
    
    
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId);
}

interface ERC721Metadata  {
    
    function name() external pure returns (string _name);

    
    function symbol() external pure returns (string _symbol);

    
    
    
    
    function tokenURI(uint256 _tokenId) external view returns (string);
}

contract LicenseAccessControl {
  


  event ContractUpgrade(address newContract);
  event Paused();
  event Unpaused();

  


  address public ceoAddress;

  


  address public cfoAddress;

  


  address public cooAddress;

  


  address public withdrawalAddress;

  bool public paused = false;

  


  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  


  modifier onlyCFO() {
    require(msg.sender == cfoAddress);
    _;
  }

  


  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  


  modifier onlyCLevel() {
    require(
      msg.sender == cooAddress ||
      msg.sender == ceoAddress ||
      msg.sender == cfoAddress
    );
    _;
  }

  


  modifier onlyCEOOrCFO() {
    require(
      msg.sender == cfoAddress ||
      msg.sender == ceoAddress
    );
    _;
  }

  


  modifier onlyCEOOrCOO() {
    require(
      msg.sender == cooAddress ||
      msg.sender == ceoAddress
    );
    _;
  }

  



  function setCEO(address _newCEO) external onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  



  function setCFO(address _newCFO) external onlyCEO {
    require(_newCFO != address(0));
    cfoAddress = _newCFO;
  }

  



  function setCOO(address _newCOO) external onlyCEO {
    require(_newCOO != address(0));
    cooAddress = _newCOO;
  }

  



  function setWithdrawalAddress(address _newWithdrawalAddress) external onlyCEO {
    require(_newWithdrawalAddress != address(0));
    withdrawalAddress = _newWithdrawalAddress;
  }

  



  function withdrawBalance() external onlyCEOOrCFO {
    require(withdrawalAddress != address(0));
    withdrawalAddress.transfer(this.balance);
  }

  

  


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused() {
    require(paused);
    _;
  }

  


  function pause() public onlyCLevel whenNotPaused {
    paused = true;
    Paused();
  }

  


  function unpause() public onlyCEO whenPaused {
    paused = false;
    Unpaused();
  }
}
