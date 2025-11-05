

pragma solidity ^0.5.0;





interface ERC721
{

  





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

  












  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
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



pragma solidity ^0.5.0;





interface ERC721TokenReceiver
{

  












  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);
    
}



pragma solidity ^0.5.0;






library SafeMath
{

  





  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {
    
    
    
    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2);
  }

  





  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {
    
    require(_divisor > 0);
    quotient = _dividend / _divisor;
    
  }

  





  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {
    require(_subtrahend <= _minuend);
    difference = _minuend - _subtrahend;
  }

  





  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {
    sum = _addend1 + _addend2;
    require(sum >= _addend1);
  }

  






  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder) 
  {
    require(_divisor != 0);
    remainder = _dividend % _divisor;
  }

}



pragma solidity ^0.5.0;





interface ERC165
{

  





  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);
    
}



pragma solidity ^0.5.0;





contract LinkerProxyNFT058 is
  NFTokenMetadata,
  NFTokenEnumerable,
  Ownable
{
  address proxyRegistryAddress;
  constructor (
    string memory _name,
    string memory _symbol
  )
    public
  {
    nftName = _name;
    nftSymbol = _symbol;
    proxyRegistryAddress = msg.sender;
  }

  



  function proxyAddress()
    external
    view
    returns (address _proxyAddress)
  {
    _proxyAddress = proxyRegistryAddress;
  }


  






  function mint(
    address _owner,
    uint256 _id,
    string calldata _uri
  )
    onlyOwner
    external
  {
    super._mint(_owner, _id);
    super._setTokenUri(_id, _uri);
    this.setApprovalForAll(proxyRegistryAddress, true);
  }

  function burn(
    uint256 _tokenId
  )
    onlyOwner
    external
  {
    super._burn(_tokenId);
  }

  






  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
  {
    if (address(proxyRegistryAddress) == _operator){
      this.setApprovalForAll(_operator, true);
    }
    this.setApprovalForAll(_operator, _approved);
  }
}



pragma solidity ^0.5.0;




