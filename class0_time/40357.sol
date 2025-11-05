pragma solidity ^0.4.18;




interface ERC721 {

    

    
    
    

    
    
    
    
    
    
    
    

    
    
    
    
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool);

    

    
    
    
    
    
    
    function ownerOf(uint256 _deedId) external view returns (address _owner);

    
    
    
    function countOfDeeds() external view returns (uint256 _count);

    
    
    
    
    function countOfDeedsByOwner(address _owner) external view returns (uint256 _count);

    
    
    
    
    
    
    
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);

    

    
    
    
    
    
    event Transfer(address indexed from, address indexed to, uint256 indexed deedId);

    
    
    
    
    
    
    
    
    event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);

    
    
    
    
    
    
    
    function approve(address _to, uint256 _deedId) external payable;

    
    
    
    
    
    function takeOwnership(uint256 _deedId) external payable;
}

contract MonsterAuction is  MonsterAuctionBase, Ownable {
    bool public isMonsterAuction = true;
    uint256 public auctionIndex = 0;

    function MonsterAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        var candidateContract = MonsterOwnership(_nftAddress);

        nonFungibleContract = candidateContract;
        ChainMonstersCore candidateCoreContract = ChainMonstersCore(_nftAddress);
        core = candidateCoreContract;
    }

    
    function setOwnerCut(uint256 _cut) external onlyOwner {
        require(_cut <= ownerCut);
        ownerCut = _cut;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    function _escrow(address _owner, uint256 _tokenId) internal {
        
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    function withdrawBalance() external onlyOwner {
        uint256 balance = this.balance;
        owner.transfer(balance);
    }

    function tokensInAuctionsOfOwner(address _owner) external view returns(uint256[] auctionTokens) {
        uint256 numAuctions = ownershipAuctionCount[_owner];

        uint256[] memory result = new uint256[](numAuctions);
        uint256 totalAuctions = core.totalSupply();
        uint256 resultIndex = 0;

        uint256 auctionId;

        for (auctionId = 0; auctionId <= totalAuctions; auctionId++) {
            Auction storage auction = tokenIdToAuction[auctionId];
            if (auction.seller == _owner) {
                result[resultIndex] = auctionId;
                resultIndex++;
            }
        }

        return result;
    }

    function createAuction(uint256 _tokenId, uint256 _price, address _seller) external {
        require(_seller != address(0));
        require(_price == uint256(_price));
        require(core._isTradeable(_tokenId));
        require(_owns(msg.sender, _tokenId));

        
        _escrow(msg.sender, _tokenId);

        Auction memory auction = Auction(
            _seller,
            uint256(_price),
            uint64(now),
            uint256(auctionIndex)
        );

        auctionIdToSeller[auctionIndex] = _seller;
        ownershipAuctionCount[_seller]++;

        auctionIndex++;
        _addAuction(_tokenId, auction);
    }

    function buy(uint256 _tokenId) external payable {
        
        
        _buy (_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    function cancelAuction(uint256 _tokenId) external {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));

        address seller = auction.seller;
        require(msg.sender == seller);

        _cancelAuction(_tokenId, seller);
    }

    function getAuction(uint256 _tokenId) external view returns (address seller, uint256 price, uint256 startedAt) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));

        return (
            auction.seller,
            auction.price,
            auction.startedAt
        );
    }

    function getPrice(uint256 _tokenId) external view returns (uint256) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return auction.price;
    }
}
