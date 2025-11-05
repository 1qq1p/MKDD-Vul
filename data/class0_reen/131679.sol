

pragma solidity ^0.5.2;





interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.2;






contract ERC721Mintable is ERC721, MinterRole {
    





    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        _mint(to, tokenId);
        return true;
    }
}



pragma solidity ^0.5.2;







