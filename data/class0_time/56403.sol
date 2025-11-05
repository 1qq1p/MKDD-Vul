pragma solidity ^0.4.24; 
interface ERC165 {
  





  function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

interface ERC721  {
    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    
    
    
    
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    
    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    
    
    
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;

    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    
    
    
    
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    
    
    
    
    
    
    function approve(address _approved, uint256 _tokenId) external;

    
    
    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


interface ERC721Enumerable  {
    
    
    
    function totalSupply() external view returns (uint256);

    
    
    
    
    
    function tokenByIndex(uint256 _index) external view returns (uint256);

    
    
    
    
    
    
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}


interface ERC721Metadata  {
  
  function name() external view returns (string _name);

  
  function symbol() external view returns (string _symbol);

  
  
  
  
  function tokenURI(uint256 _tokenId) external view returns (string);
}


interface ERC721TokenReceiver {
    
    
    
    
    
    
    
    
    
    
    
    
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
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




library AddressUtils {

  






  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    
    
    
    
    
    
    
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}
 
library UrlStr {
  
  
  
  function generateUrl(string url,uint256 _tokenId) internal pure returns (string _url){
    _url = url;
    bytes memory _tokenURIBytes = bytes(_url);
    uint256 base_len = _tokenURIBytes.length - 1;
    _tokenURIBytes[base_len - 7] = byte(48 + _tokenId / 10000000 % 10);
    _tokenURIBytes[base_len - 6] = byte(48 + _tokenId / 1000000 % 10);
    _tokenURIBytes[base_len - 5] = byte(48 + _tokenId / 100000 % 10);
    _tokenURIBytes[base_len - 4] = byte(48 + _tokenId / 10000 % 10);
    _tokenURIBytes[base_len - 3] = byte(48 + _tokenId / 1000 % 10);
    _tokenURIBytes[base_len - 2] = byte(48 + _tokenId / 100 % 10);
    _tokenURIBytes[base_len - 1] = byte(48 + _tokenId / 10 % 10);
    _tokenURIBytes[base_len - 0] = byte(48 + _tokenId / 1 % 10);
  }
}





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
 




