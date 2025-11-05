pragma solidity ^0.4.24;







library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}








contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  




  


  mapping(bytes4 => bool) internal supportedInterfaces;

  



  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  


  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  


  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}






