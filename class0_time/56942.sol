pragma solidity 0.4.21;








contract IWasFirstFungibleToken is ERC721Token("IWasFirstFungible", "IWX"), Ownable {

    struct TokenMetaData {
        uint creationTime;
        string creatorMetadataJson;
    }
    address _serviceTokenAddress;
    address _shareTokenAddress;
    mapping (uint256 => string) internal tokenHash;
    mapping (string => uint256) internal tokenIdOfHash;
    uint256 internal tokenIdSeq = 1;
    mapping (uint256 => TokenMetaData[]) internal tokenMetaData;
    
    function hashExists(string hash) public view returns (bool) {
        return tokenIdOfHash[hash] != 0;
    }

    function mint(string hash, string creatorMetadataJson) external {
        require(!hashExists(hash));
        uint256 currentTokenId = tokenIdSeq;
        tokenIdSeq = tokenIdSeq + 1;
        IWasFirstServiceToken serviceToken = IWasFirstServiceToken(_serviceTokenAddress);
        serviceToken.transferByRelatedToken(msg.sender, _shareTokenAddress, 10 ** uint256(serviceToken.DECIMALS()));
        tokenHash[currentTokenId] = hash;
        tokenIdOfHash[hash] = currentTokenId;
        tokenMetaData[currentTokenId].push(TokenMetaData(now, creatorMetadataJson));
        super._mint(msg.sender, currentTokenId);
    }

    function getTokenCreationTime(string hash) public view returns(uint) {
        require(hashExists(hash));
        uint length = tokenMetaData[tokenIdOfHash[hash]].length;
        return tokenMetaData[tokenIdOfHash[hash]][length-1].creationTime;
    }

    function getCreatorMetadata(string hash) public view returns(string) {
        require(hashExists(hash));
        uint length = tokenMetaData[tokenIdOfHash[hash]].length;
        return tokenMetaData[tokenIdOfHash[hash]][length-1].creatorMetadataJson;
    }

    function getMetadataHistoryLength(string hash) public view returns(uint) {
        if(hashExists(hash)) {
            return tokenMetaData[tokenIdOfHash[hash]].length;
        } else {
            return 0;
        }
    }

    function getCreationDateOfHistoricalMetadata(string hash, uint index) public view returns(uint) {
        require(hashExists(hash));
        return tokenMetaData[tokenIdOfHash[hash]][index].creationTime;
    }

    function getCreatorMetadataOfHistoricalMetadata(string hash, uint index) public view returns(string) {
        require(hashExists(hash));
        return tokenMetaData[tokenIdOfHash[hash]][index].creatorMetadataJson;
    }

    function updateMetadata(string hash, string creatorMetadataJson) public {
        require(hashExists(hash));
        require(ownerOf(tokenIdOfHash[hash]) == msg.sender);
        tokenMetaData[tokenIdOfHash[hash]].push(TokenMetaData(now, creatorMetadataJson));
    }

    function getTokenIdByHash(string hash) public view returns(uint256) {
        require(hashExists(hash));
        return tokenIdOfHash[hash];
    }

    function getHashByTokenId(uint256 tokenId) public view returns(string) {
        require(exists(tokenId));
        return tokenHash[tokenId];
    }

    function getNumberOfTokens() public view returns(uint) {
        return allTokens.length;
    }

    function setServiceTokenAddress(address serviceTokenAdress) onlyOwner() public {
        require(_serviceTokenAddress == address(0));
        _serviceTokenAddress = serviceTokenAdress;
    }

    function getServiceTokenAddress() public view returns(address) {
        return _serviceTokenAddress;
    }

    function setShareTokenAddress(address shareTokenAdress) onlyOwner() public {
        require(_shareTokenAddress == address(0));
        _shareTokenAddress = shareTokenAdress;
    }

    function getShareTokenAddress() public view returns(address) {
        return _shareTokenAddress;
    }
}


