pragma solidity ^0.4.21;


contract REPOPCore is REPOPERC721, MoneyManager{
    uint256 public refresherFee = 0.01 ether;
    AuctionManager public auctionManager;
    MarketManager public marketManager;
    GenesMarket public genesMarket;
    CloningInterface public geneScience;

    event CloneWithTwoPops(address creator, uint256 cloneId, uint256 aParentId, uint256 bParentId);
    event CloneWithPopAndBottle(address creator, uint256 cloneId, uint256 popId, uint256 bottleId);
    event SellingPop(address seller, uint256 popId, uint256 price);
    event SellingGenes(address seller, uint256 popId, uint256 price);
    event ChangedPopName(address owner, uint256 popId, bytes32 newName);
    event CooldownRemoval(uint256 popId, address owner, uint256 paidFee);

    function REPOPCore() public{

      ceoAddress = msg.sender;
      cooAddress = msg.sender;
      cfoAddress = msg.sender;

      createNewPop(0x0, "Satoshi Nakamoto");
    }

    function createNewAuction(uint256 _itemForAuctionID, uint256 _auctionDurationSeconds) public onlyCLevel{
        approve(address(auctionManager),_itemForAuctionID);
        auctionManager.createAuction(_itemForAuctionID,_auctionDurationSeconds,msg.sender);
    }

    function setAuctionManagerAddress(address _address) external onlyCEO {
        AuctionManager candidateContract = AuctionManager(_address);


        require(candidateContract.isAuctionManager());


        auctionManager = candidateContract;
    }

    function getAuctionManagerAddress() public view returns (address) {
        return address(auctionManager);
    }

    function setMarketManagerAddress(address _address) external onlyCEO {
        MarketManager candidateContract = MarketManager(_address);
        require(candidateContract.isMarketManager());
        marketManager = candidateContract;
    }

    function getMarketManagerAddress() public view returns (address) {
        return address(marketManager);
    }

    function setGeneScienceAddress(address _address) external onlyCEO {
      CloningInterface candidateContract = CloningInterface(_address);
      require(candidateContract.isGeneScience());
      geneScience = candidateContract;
    }

    function getGeneScienceAddress() public view returns (address) {
        return address(geneScience);
    }

    function setGenesMarketAddress(address _address) external onlyCEO {
      GenesMarket candidateContract = GenesMarket(_address);
      require(candidateContract.isGenesMarket());
      genesMarket = candidateContract;
    }

    function getGenesMarketAddress() public view returns (address) {
        return address(genesMarket);
    }

    function sellPop(uint256 _popId, uint256 _price) public {
        Pop storage pop = pops[_popId];
        require(pop.cooldownEndTimestamp <= now);
        approve(address(marketManager),_popId);
        marketManager.sellPop(msg.sender,_popId,_price);
        emit SellingPop(msg.sender, _popId, _price);
    }

    function sellGenes(uint256 _popId, uint256 _price) public {
        require(_popId > 0);
        approve(address(genesMarket),_popId);
        genesMarket.startSellingGenes(_popId,_price,msg.sender);
        emit SellingGenes(msg.sender, _popId, _price);
    }

    function getOwnerInAnyPlatformById(uint256 popId) public view returns (address){
      if(ownerOf(popId) == address(marketManager)){
        return marketManager.sellerOf(popId);
      }
      else if(ownerOf(popId) == address(genesMarket)){
        return genesMarket.sellerOf(popId);
      }
      else if(ownerOf(popId) == address(auctionManager)){
        return ceoAddress;
      }
      else{
        return ownerOf(popId);
      }
      return 0x0;
    }

    function setPopName(uint256 popId, string newName) external {
      require(_ownerOfPopInAnyPlatform(popId));
      Pop storage pop = pops[popId];
      require(pop.generation > 0);
      bytes32 name32 = stringToBytes32(newName);
      pop.popName = name32;
      emit ChangedPopName(msg.sender, popId, name32);
    }

    function removeCooldown(uint256 popId)
      external
      payable
      {
        require(_ownerOfPopInAnyPlatform(popId));
        require(msg.value >= refresherFee);
        Pop storage pop = pops[popId];
        pop.cooldownEndTimestamp = 1;
        emit CooldownRemoval(popId, msg.sender, refresherFee);
      }

    function _ownerOfPopInAnyPlatform(uint _popId) internal view returns (bool) {
      return ownerOf(_popId) == msg.sender || genesMarket.sellerOf(_popId) == msg.sender || marketManager.sellerOf(_popId) == msg.sender;
    }

    function getOwnershipForCloning(uint _popId) internal view returns (bool) {
        return ownerOf(_popId) == msg.sender || genesMarket.sellerOf(_popId) == msg.sender;
    }

    function changeRefresherFee(uint256 _newFee) public onlyCLevel{
        refresherFee = _newFee;
    }

    function cloneWithTwoPops(uint256 _aParentId, uint256 _bParentId)
      external
      whenNotPaused
      returns (uint256)
      {
        require(_aParentId > 0);
        require(_bParentId > 0);
        require(getOwnershipForCloning(_aParentId));
        require(getOwnershipForCloning(_bParentId));
        Pop storage aParent = pops[_aParentId];

        Pop storage bParent = pops[_bParentId];

        require(aParent.genes != bParent.genes);
        require(aParent.cooldownEndTimestamp <= now);
        require(bParent.cooldownEndTimestamp <= now);

        uint16 parentGen = aParent.generation;
        if (bParent.generation > aParent.generation) {
            parentGen = bParent.generation;
        }

        uint16 cooldownIndex = parentGen + 1;
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        uint256 childGenes = geneScience.mixGenes(aParent.genes, bParent.genes);

        _triggerCooldown(aParent);
        _triggerCooldown(bParent);

        uint256 index = pops.push(Pop(childGenes,uint64(now), 1, uint32(_aParentId), uint32(_bParentId), 0, cooldownIndex, parentGen + 1)) -1;

        popIndexToOwner[index] = msg.sender;
        ownershipTokenCount[msg.sender] = ownershipTokenCount[msg.sender]+1;

        emit CloneWithTwoPops(msg.sender, index, _aParentId, _bParentId);
        emit Birth(msg.sender, index, _aParentId, _bParentId,childGenes);

        return index;
    }

    function cloneWithPopAndBottle(uint256 _aParentId, uint256 _bParentId_bottle)
        external
        whenNotPaused
        returns (uint256)
        {
          require(_aParentId > 0);
          require(getOwnershipForCloning(_aParentId));
          Pop storage aParent = pops[_aParentId];
          Pop memory bParent = pops[_bParentId_bottle];

          require(aParent.genes != bParent.genes);
          require(aParent.cooldownEndTimestamp <= now);

          uint16 parentGen = aParent.generation;
          if (bParent.generation > aParent.generation) {
              parentGen = bParent.generation;
          }

          uint16 cooldownIndex = parentGen + 1;
          if (cooldownIndex > 13) {
              cooldownIndex = 13;
          }

          genesMarket.useBottle(msg.sender, _bParentId_bottle);

          uint256 childGenes = geneScience.mixGenes(aParent.genes, bParent.genes);

          _triggerCooldown(aParent);

          uint256 index = pops.push(Pop(childGenes,uint64(now), 1, uint32(_aParentId), uint32(_bParentId_bottle), 0, cooldownIndex, parentGen + 1)) -1;

          popIndexToOwner[index] = msg.sender;
          ownershipTokenCount[msg.sender] = ownershipTokenCount[msg.sender]+1;

          emit CloneWithPopAndBottle(msg.sender, index, _aParentId, _bParentId_bottle);
          emit Birth(msg.sender, index, _aParentId, _bParentId_bottle, childGenes);

          return index;
        }
}