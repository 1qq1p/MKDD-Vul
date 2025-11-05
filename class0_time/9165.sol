pragma solidity ^0.4.18;

contract SkinMarket is SkinMix {

    
    
    uint128 public trCut = 400;

    
    mapping (uint256 => uint256) public desiredPrice;

    
    event PutOnSale(address account, uint256 skinId);
    event WithdrawSale(address account, uint256 skinId);
    event BuyInMarket(address buyer, uint256 skinId);

    

    function setTrCut(uint256 newCut) external onlyCOO {
        trCut = uint128(newCut);
    }

    
    function putOnSale(uint256 skinId, uint256 price) public whenNotPaused {
        
        require(skinIdToOwner[skinId] == msg.sender);

        
        require(skins[skinId].mixingWithId == 0);

        
        require(isOnSale[skinId] == false);

        require(price > 0); 

        
        desiredPrice[skinId] = price;
        isOnSale[skinId] = true;

        
        PutOnSale(msg.sender, skinId);
    }
  
    
    function withdrawSale(uint256 skinId) external whenNotPaused {
        
        require(isOnSale[skinId] == true);
        
        
        require(skinIdToOwner[skinId] == msg.sender);

        
        isOnSale[skinId] = false;
        desiredPrice[skinId] = 0;

        
        WithdrawSale(msg.sender, skinId);
    }
 
    
    function buyInMarket(uint256 skinId) external payable whenNotPaused {
        
        require(isOnSale[skinId] == true);

        address seller = skinIdToOwner[skinId];

        
        require(msg.sender != seller);

        uint256 _price = desiredPrice[skinId];
        
        require(msg.value >= _price);

        
        uint256 sellerProceeds = _price - _computeCut(_price);

        seller.transfer(sellerProceeds);

        
        numSkinOfAccounts[seller] -= 1;
        skinIdToOwner[skinId] = msg.sender;
        numSkinOfAccounts[msg.sender] += 1;
        isOnSale[skinId] = false;
        desiredPrice[skinId] = 0;

        
        BuyInMarket(msg.sender, skinId);
    }

    
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * trCut / 10000;
    }
}
