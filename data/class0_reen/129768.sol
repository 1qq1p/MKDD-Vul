pragma solidity ^0.4.24;







library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



interface IEntityStorage {
    function storeBulk(uint256[] _tokenIds, uint256[] _attributes) external;
    function store(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external;
    function remove(uint256 _tokenId) external;
    function list() external view returns (uint256[] tokenIds);
    function getAttributes(uint256 _tokenId) external view returns (uint256 attrs, uint256[] compIds);
    function updateAttributes(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external;
    function totalSupply() external view returns (uint256);
}








contract CBCreatureStorage is Ownable, IEntityStorage { 
    using SafeMath for uint256;  

    struct Token {
        uint256 tokenId;
        uint256 attributes;
        uint256[] componentIds;
        uint index;
    }

    
    uint256[] internal allTokens;

    
    mapping(uint256 => Token) internal tokens;

    event Stored(uint256 tokenId, uint256 attributes, uint256[] componentIds);
    event Removed(uint256 tokenId);

    


    constructor() public {
    }

    




    function exists(uint256 _tokenId) public view returns (bool) {
        return tokens[_tokenId].tokenId == _tokenId;
    }

    




    function storeBulk(uint256[] _tokenIds, uint256[] _attributes) external onlyOwnerOrController {
        uint256[] memory _componentIds;
        uint startIndex = allTokens.length;
        for (uint index = 0; index < _tokenIds.length; index++) {
            require(!this.exists(_tokenIds[index]));
            allTokens.push(_tokenIds[index]);
            tokens[_tokenIds[index]] = Token(_tokenIds[index], _attributes[index], _componentIds, startIndex + index);
            emit Stored(_tokenIds[index], _attributes[index], _componentIds);
        }
    }
    
    





    function store(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {
        require(!this.exists(_tokenId));
        allTokens.push(_tokenId);
        tokens[_tokenId] = Token(_tokenId, _attributes, _componentIds, allTokens.length - 1);
        emit Stored(_tokenId, _attributes, _componentIds);
    }

    



    function remove(uint256 _tokenId) external onlyOwnerOrController {
        require(_tokenId > 0);
        require(exists(_tokenId));
        
        uint doomedTokenIndex = tokens[_tokenId].index;
        
        delete tokens[_tokenId];

        
        uint lastTokenIndex = allTokens.length.sub(1);
        uint256 lastTokenId = allTokens[lastTokenIndex];

        
        tokens[lastTokenId].index = doomedTokenIndex;
        
        allTokens[doomedTokenIndex] = lastTokenId;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        emit Removed(_tokenId);
    }

    


    function list() external view returns (uint256[] tokenIds) {
        return allTokens;
    }

    



    function getAttributes(uint256 _tokenId) external view returns (uint256 attrs, uint256[] compIds) {
        require(exists(_tokenId));
        return (tokens[_tokenId].attributes, tokens[_tokenId].componentIds);
    }

    





    function updateAttributes(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {
        require(exists(_tokenId));
        require(_attributes > 0);
        tokens[_tokenId].attributes = _attributes;
        tokens[_tokenId].componentIds = _componentIds;
        emit Stored(_tokenId, _attributes, _componentIds);
    }

    


    function totalSupply() external view returns (uint256) {
        return allTokens.length;
    }

}