pragma solidity ^0.5.0;





interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





contract ERC721Burnable is ERC721, Ownable {
    



    function burn(uint256 tokenId) public onlyOwner {
        
        _burn(tokenId);
    }
}
