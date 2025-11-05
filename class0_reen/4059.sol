pragma solidity ^0.4.24;


contract KydyBase is KydyAccessControl, ERC721Basic {
    using SafeMath for uint256;
    using Address for address;

    

    


    event Created(address indexed owner, uint256 kydyId, uint256 yinId, uint256 yangId, uint256 genes);

    

    


    struct Kydy {
        
        uint256 genes;

        
        uint64 createdTime;

        
        uint64 rechargeEndBlock;

        
        uint32 yinId;
        uint32 yangId;

        
        uint32 synthesizingWithId;

        
        
        uint16 rechargeIndex;

        
        
        uint16 generation;
    }

    

    



    uint32[14] public recharges = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days)
    ];

    
    uint256 public secondsPerBlock = 15;

    

    


    Kydy[] kydys;

    



    mapping (uint256 => address) internal kydyIndexToOwner;

    



    mapping (address => uint256) internal ownershipTokenCount;

    



    mapping (uint256 => address) internal kydyIndexToApproved;

    



    mapping (uint256 => address) internal synthesizeAllowedToAddress;

    


    mapping (address => mapping (address => bool)) private _operatorApprovals;

    




    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = kydyIndexToOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    




    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return kydyIndexToApproved[tokenId];
    }

    




    function getSynthesizeApproved(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId));
        return synthesizeAllowedToAddress[tokenId];
    }

    





    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    




    function setApprovalForAll(address to, bool approved) external {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
        
        kydyIndexToOwner[_tokenId] = _to;

        ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
        
        delete synthesizeAllowedToAddress[_tokenId];
        
        delete kydyIndexToApproved[_tokenId];

        
        emit Transfer(_from, _to, _tokenId);
    }

    




    function _exists(uint256 _tokenId) internal view returns (bool) {
        address owner = kydyIndexToOwner[_tokenId];
        return owner != address(0);
    }

    





    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        
        
        
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    




    function _addTokenTo(address _to, uint256 _tokenId) internal {
        
        require(kydyIndexToOwner[_tokenId] == address(0));
        
        kydyIndexToOwner[_tokenId] = _to;
        
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
    }

    




    function _removeTokenFrom(address _from, uint256 _tokenId) internal {
        
        require(ownerOf(_tokenId) == _from);
        
        ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
        
        kydyIndexToOwner[_tokenId] = address(0);
    }

    




    function _mint(address _to, uint256 _tokenId) internal {
        require(!_exists(_tokenId));
        _addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    




    function _clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (kydyIndexToApproved[_tokenId] != address(0)) {
            kydyIndexToApproved[_tokenId] = address(0);
        }
        if (synthesizeAllowedToAddress[_tokenId] != address(0)) {
            synthesizeAllowedToAddress[_tokenId] = address(0);
        }
    }

    







    function _createKydy(
        uint256 _yinId,
        uint256 _yangId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_yinId == uint256(uint32(_yinId)));
        require(_yangId == uint256(uint32(_yangId)));
        require(_generation == uint256(uint16(_generation)));

        
        uint16 rechargeIndex = uint16(_generation / 2);
        if (rechargeIndex > 13) {
            rechargeIndex = 13;
        }

        Kydy memory _kyd = Kydy({
            genes: _genes,
            createdTime: uint64(now),
            rechargeEndBlock: 0,
            yinId: uint32(_yinId),
            yangId: uint32(_yangId),
            synthesizingWithId: 0,
            rechargeIndex: rechargeIndex,
            generation: uint16(_generation)
        });
        uint256 newbabyKydyId = kydys.push(_kyd) - 1;

        
        require(newbabyKydyId == uint256(uint32(newbabyKydyId)));

        
        emit Created(
            _owner,
            newbabyKydyId,
            uint256(_kyd.yinId),
            uint256(_kyd.yangId),
            _kyd.genes
        );

        
        _mint(_owner, newbabyKydyId);

        return newbabyKydyId;
    }

    
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < recharges[0]);
        secondsPerBlock = secs;
    }
}





