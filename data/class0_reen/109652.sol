pragma solidity ^0.4.24;






interface ERC721 {

  





  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  




  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  



  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  




  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);

  




  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  











  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    external;

  







  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  









  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  






  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;

  






  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;

  




  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  




  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);

}






interface ERC721TokenReceiver {

  











  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    external
    returns(bytes4);
    
}







library SafeMath {

  




  function mul(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {
    if (_a == 0) {
      return 0;
    }
    uint256 c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  




  function div(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {
    uint256 c = _a / _b;
    
    
    return c;
  }

  




  function sub(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {
    assert(_b <= _a);
    return _a - _b;
  }

  




  function add(
    uint256 _a,
    uint256 _b
  )
    internal
    pure
    returns (uint256)
  {
    uint256 c = _a + _b;
    assert(c >= _a);
    return c;
  }

}






interface ERC165 {

  




  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);

}






contract SupportsInterface is
  ERC165
{

  



  mapping(bytes4 => bool) internal supportedInterfaces;

  


  constructor()
    public
  {
    supportedInterfaces[0x01ffc9a7] = true; 
  }

  



  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceID];
  }

}






library AddressUtils {

  



  function isContract(
    address _addr
  )
    internal
    view
    returns (bool)
  {
    uint256 size;

    






    assembly { size := extcodesize(_addr) } 
    return size > 0;
  }

}





