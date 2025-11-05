pragma solidity ^0.5.0;





interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    
    string private _name;

    
    string private _symbol;

    
    mapping(uint256 => string) private _tokenURIs;
    
    string _tokenURI;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    






    


    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    



    function name() external view returns (string memory) {
        return _name;
    }

    



    function symbol() external view returns (string memory) {
        return _symbol;
    }

    




    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        
        return _tokenURI;
    }

    





    function _setTokenURI(uint256 tokenId, string memory uri) internal {
            _tokenURI = uri;
            
            
    }

    






    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}






