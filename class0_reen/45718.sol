pragma solidity ^0.4.11;







contract PetMinting is PetAuction {

    
    uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant GEN0_CREATION_LIMIT = 45000;

    
    uint256 public constant GEN0_STARTING_PRICE = 100 szabo; 
    uint256 public constant GEN0_AUCTION_DURATION = 14 days;


    
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    
    
    
    function createPromoPet(uint256 _genes, address _owner, uint256 _grade, uint256 _level, uint256 _params, uint256 _skills) external onlyCOO {
        address petOwner = _owner;
        if (petOwner == address(0)) {
            petOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        _createPet(0, _genes, petOwner, _grade, _level, _params, _skills);
    }

    
    
    function createGen0Auction(uint256 _genes, uint256 _grade, uint256 _level, uint256 _params, uint256 _skills) external onlyCOO {
        require(gen0CreatedCount < GEN0_CREATION_LIMIT);

        uint256 petId = _createPet(0, _genes, address(this), _grade, _level, _params, _skills);
        _approve(petId, saleAuction);

        saleAuction.createAuction(
            petId,
            GEN0_STARTING_PRICE,
            0,
            GEN0_AUCTION_DURATION,
            address(this)
        );

        gen0CreatedCount++;
    }

}
	
	
	


