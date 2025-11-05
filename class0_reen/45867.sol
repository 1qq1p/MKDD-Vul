pragma solidity ^0.4.18;

contract LEN is MiniMeToken, Blockeds {
  bool public StorageEnabled = true;

  modifier onlyStorageEnabled() {
    require(StorageEnabled);
    _;
  }

  modifier onlyNotBlocked(address _addr) {
    require(!blocked[_addr]);
    _;
  }

  event StorageEnabled(bool _StorageEnabled);

  function LEN(address _tokenFactory) MiniMeToken(
    _tokenFactory,
    0x0,                  
    0,                    
    "Lending Token",      
    18,                   
    "LEN",                
    false                 
  ) public {}

  function transfer(address _to, uint256 _amount) public onlyNotBlocked(msg.sender) returns (bool success) {
    return super.transfer(_to, _amount);
  }

  function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _amount);
  }

  
  
  function generateTokens(address _owner, uint _amount) public onlyController onlyStorageEnabled returns (bool) {
    return super.generateTokens(_owner, _amount);
  }

  function destroyTokens(address _owner, uint _amount) public onlyController onlyStorageEnabled returns (bool) {
    return super.destroyTokens(_owner, _amount);
  }

  function blockAddress(address _addr) public onlyController onlyStorageEnabled {
    super.blockAddress(_addr);
  }

  function unblockAddress(address _addr) public onlyController onlyStorageEnabled {
    super.unblockAddress(_addr);
  }

  function enableStorage(bool _StorageEnabled) public onlyController {
    StorageEnabled = _StorageEnabled;
    StorageEnabled(_StorageEnabled);
  }

  
  function generateTokensByList(address[] _owners, uint[] _amounts) public onlyController onlyStorageEnabled returns (bool) {
    require(_owners.length == _amounts.length);

    for(uint i = 0; i < _owners.length; i++) {
      generateTokens(_owners[i], _amounts[i]);
    }

    return true;
  }
}