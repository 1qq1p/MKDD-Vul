pragma solidity ^0.4.18;








contract EtherbotsNFT is EtherbotsBase, ERC721Enumerable, ERC721Original {
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return (_interfaceID == ERC721Original.INTERFACE_SIGNATURE_ERC721Original) ||
            (_interfaceID == ERC721.INTERFACE_SIGNATURE_ERC721) ||
            (_interfaceID == ERC721Metadata.INTERFACE_SIGNATURE_ERC721Metadata) ||
            (_interfaceID == ERC721Enumerable.INTERFACE_SIGNATURE_ERC721Enumerable);
    }
    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function name() public pure returns (string _name) {
      return "Etherbots";
    }

    function symbol() public pure returns (string _smbol) {
      return "ETHBOT";
    }

    
    
    function totalSupply() public view returns (uint) {
        return parts.length;
    }

    
    
    function countOfDeeds() external view returns (uint256) {
        return parts.length;
    }

    
    
    function owns(address _owner, uint256 _tokenId) public view returns (bool) {
        return (partIndexToOwner[_tokenId] == _owner);
    }

    
    
    function ownsAll(address _owner, uint256[] _tokenIds) public view returns (bool) {
        require(_tokenIds.length > 0);
        for (uint i = 0; i < _tokenIds.length; i++) {
            if (partIndexToOwner[_tokenIds[i]] != _owner) {
                return false;
            }
        }
        return true;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        partIndexToApproved[_tokenId] = _approved;
    }

    function _approvedFor(address _newOwner, uint256 _tokenId) internal view returns (bool) {
        return (partIndexToApproved[_tokenId] == _newOwner);
    }

    function ownerByIndex(uint256 _index) external view returns (address _owner){
        return partIndexToOwner[_index];
    }

    
    function balanceOf(address _owner) public view returns (uint256 count) {
        return addressToTokensOwned[_owner];
    }

    function countOfDeedsByOwner(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }

    
    function transfer(address _to, uint256 _tokenId) public whenNotPaused payable {
        
        require(msg.value == 0);

        
        require(_to != address(0));
        require(_to != address(this));
        
        require(_to != address(auction));
        
        for (uint j = 0; j < approvedBattles.length; j++) {
            require(_to != approvedBattles[j]);
        }

        
        require(owns(msg.sender, _tokenId));

        
        _transfer(msg.sender, _to, _tokenId);
    }
    

    function transferAll(address _to, uint256[] _tokenIds) public whenNotPaused payable {
        require(msg.value == 0);

        
        require(_to != address(0));
        require(_to != address(this));
        
        require(_to != address(auction));
        
        for (uint j = 0; j < approvedBattles.length; j++) {
            require(_to != approvedBattles[j]);
        }

        
        require(ownsAll(msg.sender, _tokenIds));

        for (uint k = 0; k < _tokenIds.length; k++) {
            
            _transfer(msg.sender, _to, _tokenIds[k]);
        }


    }


    
    
    function approve(address _to, uint256 _deedId) external whenNotPaused payable {
        
        require(msg.value == 0);

        
        require(owns(msg.sender, _deedId));

        
        partIndexToApproved[_deedId] = _to;

        Approval(msg.sender, _to, _deedId);
    }

    
    function approveMany(address _to, uint256[] _tokenIds) external whenNotPaused payable {

        for (uint i = 0; i < _tokenIds.length; i++) {
            uint _tokenId = _tokenIds[i];

            
            require(owns(msg.sender, _tokenId));

            
            partIndexToApproved[_tokenId] = _to;
            
            Approval(msg.sender, _to, _tokenId);
        }
    }

    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {

        
        require(_to != address(0));
        require(_to != address(this));

        
        require(partIndexToApproved[_tokenId] == msg.sender);
        
        require(owns(_from, _tokenId));

        
        _transfer(_from, _to, _tokenId);
    }

    
    function ownerOf(uint256 _deedId) public view returns (address _owner) {
        _owner = partIndexToOwner[_deedId];
        
        require(_owner != address(0));
    }

    
    
    
    
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 totalParts = totalSupply();

        return tokensOfOwnerWithinRange(_owner, 0, totalParts);
  
    }

    function tokensOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tmpResult = new uint256[](tokenCount);
        if (tokenCount == 0) {
            return tmpResult;
        }

        uint256 resultIndex = 0;
        for (uint partId = _start; partId < _start + _numToSearch; partId++) {
            if (partIndexToOwner[partId] == _owner) {
                tmpResult[resultIndex] = partId;
                resultIndex++;
                if (resultIndex == tokenCount) { 
                    break;
                }
            }
        }

        
        uint resultLength = resultIndex;
        uint256[] memory result = new uint256[](resultLength);
        for (uint i=0; i<resultLength; i++) {
            result[i] = tmpResult[i];
        }
        return result;
    }



    
    
    function getPartsOfOwner(address _owner) external view returns(bytes24[]) {
        uint256 totalParts = totalSupply();

        return getPartsOfOwnerWithinRange(_owner, 0, totalParts);
    }
    
    
    
    function getPartsOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(bytes24[]) {
        uint256 tokenCount = balanceOf(_owner);

        uint resultIndex = 0;
        bytes24[] memory result = new bytes24[](tokenCount);
        for (uint partId = _start; partId < _start + _numToSearch; partId++) {
            if (partIndexToOwner[partId] == _owner) {
                result[resultIndex] = _partToBytes(parts[partId]);
                resultIndex++;
            }
        }
        return result; 
    }


    function _partToBytes(Part p) internal pure returns (bytes24 b) {
        b = bytes24(p.tokenId);

        b = b << 8;
        b = b | bytes24(p.partType);

        b = b << 8;
        b = b | bytes24(p.partSubType);

        b = b << 8;
        b = b | bytes24(p.rarity);

        b = b << 8;
        b = b | bytes24(p.element);

        b = b << 32;
        b = b | bytes24(p.battlesLastDay);

        b = b << 32;
        b = b | bytes24(p.experience);

        b = b << 32;
        b = b | bytes24(p.forgeTime);

        b = b << 32;
        b = b | bytes24(p.battlesLastReset);
    }

    uint32 constant FIRST_LEVEL = 1000;
    uint32 constant INCREMENT = 1000;

    
    function getLevel(uint32 _exp) public pure returns(uint32) {
        uint32 c = 0;
        for (uint32 i = FIRST_LEVEL; i <= FIRST_LEVEL + _exp; i += c * INCREMENT) {
            c++;
        }
        return c;
    }

    string metadataBase = "https://api.etherbots.io/api/";


    function setMetadataBase(string _base) external onlyOwner {
        metadataBase = _base;
    }

    
    
    function _metadata(uint256 _id) internal view returns(string) {
        Part memory p = parts[_id];
        return strConcat(strConcat(
            metadataBase,
            uintToString(uint(p.partType)),
            "/",
            uintToString(uint(p.partSubType)),
            "/"
        ), uintToString(uint(p.rarity)), "", "", "");
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function deedUri(uint256 _deedId) external view returns (string _uri){
        return _metadata(_deedId);
    }

    
    function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl) {
        return _metadata(_tokenId);
    }

    function takeOwnership(uint256 _deedId) external payable {
        
        require(msg.value == 0);

        address _from = partIndexToOwner[_deedId];

        require(_approvedFor(msg.sender, _deedId));

        _transfer(_from, msg.sender, _deedId);
    }

    
    function deedByIndex(uint256 _index) external view returns (uint256 _deedId){
        return _index;
    }

    function countOfOwners() external view returns (uint256 _count){
        
        return 0;
    }


    function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint _tokenId){
        return _tokenOfOwnerByIndex(_owner, _index);
    }


    function _tokenOfOwnerByIndex(address _owner, uint _index) private view returns (uint _tokenId){
        
        require(_index < balanceOf(_owner));

        
        uint256 seen = 0;
        uint256 totalTokens = totalSupply();

        for (uint i = 0; i < totalTokens; i++) {
            if (partIndexToOwner[i] == _owner) {
                if (seen == _index) {
                    return i;
                }
                seen++;
            }
        }
    }

    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId){
        return _tokenOfOwnerByIndex(_owner, _index);
    }
}








