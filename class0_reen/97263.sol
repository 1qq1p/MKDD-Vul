pragma solidity ^0.4.24;







interface IERC165 {

  





  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}







contract ERC165 is IERC165 {

  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
  




  


  mapping(bytes4 => bool) internal _supportedInterfaces;

  



  constructor()
    public
  {
    _registerInterface(_InterfaceId_ERC165);
  }

  


  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool)
  {
    return _supportedInterfaces[interfaceId];
  }

  


  function _registerInterface(bytes4 interfaceId)
    internal
  {
    require(interfaceId != 0xffffffff);
    _supportedInterfaces[interfaceId] = true;
  }
}






