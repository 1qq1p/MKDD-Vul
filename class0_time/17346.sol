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





contract Core is LootboxStore, ExternalInterface {
  mapping(address => uint256) authorizedExternal;

  function addAuthorizedExternal(address _address) external onlyOwner {
    authorizedExternal[_address] = 1;
  }

  function removeAuthorizedExternal(address _address) external onlyOwner {
    delete authorizedExternal[_address];
  }

  
  modifier onlyAuthorized() { 
    require(ethPricedLootboxes[msg.sender] != 0 ||
            authorizedExternal[msg.sender] != 0);
      _; 
  }

  function giveItem(address _recipient, uint256 _traits) onlyAuthorized external {
    _createToken(_recipient, _traits);
  }

  function giveMultipleItems(address _recipient, uint256[] _traits) onlyAuthorized external {
    for (uint i = 0; i < _traits.length; ++i) {
      _createToken(_recipient, _traits[i]);
    }
  }

  function giveMultipleItemsToMultipleRecipients(address[] _recipients, uint256[] _traits) onlyAuthorized external {
    require(_recipients.length == _traits.length);

    for (uint i = 0; i < _traits.length; ++i) {
      _createToken(_recipients[i], _traits[i]);
    }
  }

  function giveMultipleItemsAndDestroyMultipleItems(address _recipient, uint256[] _traits, uint256[] _tokenIds) onlyAuthorized external {
    for (uint i = 0; i < _traits.length; ++i) {
      _createToken(_recipient, _traits[i]);
    }

    for (i = 0; i < _tokenIds.length; ++i) {
      _burnFor(ownerOf(_tokenIds[i]), _tokenIds[i]);
    }
  }

  function destroyItem(uint256 _tokenId) onlyAuthorized external {
    _burnFor(ownerOf(_tokenId), _tokenId);
  }

  function destroyMultipleItems(uint256[] _tokenIds) onlyAuthorized external {
    for (uint i = 0; i < _tokenIds.length; ++i) {
      _burnFor(ownerOf(_tokenIds[i]), _tokenIds[i]);
    }
  }

  function updateItemTraits(uint256 _tokenId, uint256 _traits) onlyAuthorized external {
    _updateToken(_tokenId, _traits);
  }
}

