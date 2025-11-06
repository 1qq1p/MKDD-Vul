pragma solidity ^0.4.23;






library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function mul(int256 a, int256 b) internal pure returns (int256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); 

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); 
        require(!(b == -1 && a == INT256_MIN)); 

        int256 c = a / b;

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    


    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface ERC721 {
    
    function totalSupply() external view returns (uint256 total);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) external view returns (address owner);

    function approve(address _to, uint256 _tokenId) external;

    function transfer(address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    
    
    
    
    

    
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}


contract PonyAuction is PonyBreeding {

    
    
    
    

    
    
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        
        require(candidateContract.isSaleClockAuction());

        
        saleAuction = candidateContract;
    }

    
    
    function setSiringAuctionAddress(address _address) external onlyCEO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);

        
        require(candidateContract.isSiringClockAuction());

        
        siringAuction = candidateContract;
    }

    
    
    function setBiddingAuctionAddress(address _address) external onlyCEO {
        BiddingClockAuction candidateContract = BiddingClockAuction(_address);

        
        require(candidateContract.isBiddingClockAuction());

        
        biddingAuction = candidateContract;
    }


    
    
    function createEthSaleAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        
        
        
        require(_owns(msg.sender, _PonyId));
        
        
        
        require(!isPregnant(_PonyId));
        _approve(_PonyId, saleAuction);
        
        
        saleAuction.createEthAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }


    
    
    function delegateDklSaleAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), saleAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        
        
        
        require(_owns(from, _tokenId));
        
        
        
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, saleAuction, _tokenId, _nonce);
        
        
        saleAuction.createDklAuction(
            _tokenId,
            from,
            _price
        );
    }


    
    
    function delegateDklSiringAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), siringAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        
        
        
        require(_owns(from, _tokenId));
        
        
        
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, siringAuction, _tokenId, _nonce);
        
        
        siringAuction.createDklAuction(
            _tokenId,
            from,
            _price
        );
    }

    
    
    function delegateDklBidAuction(
        uint256 _tokenId,
        uint256 _price,
        bytes _ponySig,
        uint256 _nonce,
        uint16 _durationIndex
    )
    external
    whenNotPaused
    {
        bytes32 hashedTx = approvePreSignedHashing(address(this), biddingAuction, _tokenId, _nonce);
        address from = recover(hashedTx, _ponySig);
        
        
        
        require(_owns(from, _tokenId));
        
        
        
        require(!isPregnant(_tokenId));
        approvePreSigned(_ponySig, biddingAuction, _tokenId, _nonce);
        
        
        biddingAuction.createDklAuction(_tokenId, from, _durationIndex, _price);
    }


    
    
    
    function createEthSiringAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        
        
        
        require(_owns(msg.sender, _PonyId));
        require(isReadyToMate(_PonyId));
        _approve(_PonyId, siringAuction);
        
        
        siringAuction.createEthAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    
    
    function createDklSaleAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        
        
        
        require(_owns(msg.sender, _PonyId));
        
        
        
        require(!isPregnant(_PonyId));
        _approve(_PonyId, saleAuction);
        
        
        saleAuction.createDklAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    
    
    
    function createDklSiringAuction(
        uint256 _PonyId,
        uint256 _price
    )
    external
    whenNotPaused
    {
        
        
        
        require(_owns(msg.sender, _PonyId));
        require(isReadyToMate(_PonyId));
        _approve(_PonyId, siringAuction);
        
        
        siringAuction.createDklAuction(
            _PonyId,
            msg.sender,
            _price
        );
    }

    function createEthBidAuction(
        uint256 _ponyId,
        uint256 _price,
        uint16 _durationIndex
    ) external whenNotPaused {
        require(_owns(msg.sender, _ponyId));
        _approve(_ponyId, biddingAuction);
        biddingAuction.createETHAuction(_ponyId, msg.sender, _durationIndex, _price);
    }

    function createDeklaBidAuction(
        uint256 _ponyId,
        uint256 _price,
        uint16 _durationIndex
    ) external whenNotPaused {
        require(_owns(msg.sender, _ponyId));
        _approve(_ponyId, biddingAuction);
        biddingAuction.createDklAuction(_ponyId, msg.sender, _durationIndex, _price);
    }

    
    
    
    
    function bidOnEthSiringAuction(
        uint256 _sireId,
        uint256 _matronId,
        uint8 _incubator,
        bytes _sig
    )
    external
    payable
    whenNotPaused
    {
        
        require(_owns(msg.sender, _matronId));
        require(isReadyToMate(_matronId));
        require(canMateWithViaAuction(_matronId, _sireId));

        
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);

        
        siringAuction.bidEth.value(msg.value - autoBirthFee)(_sireId);
        if (_incubator == 0 && hasIncubator[msg.sender]) {
            _mateWith(_matronId, _sireId, _incubator);
        } else {
            bytes32 hashedTx = getIncubatorHashing(msg.sender, _incubator, nonces[msg.sender]);
            require(signedBySystem(hashedTx, _sig));
            nonces[msg.sender]++;

            
            if (!hasIncubator[msg.sender]) {
                hasIncubator[msg.sender] = true;
            }
            _mateWith(_matronId, _sireId, _incubator);
        }
    }

    
    
    
    
    function bidOnDklSiringAuction(
        uint256 _sireId,
        uint256 _matronId,
        uint8 _incubator,
        bytes _incubatorSig,
        uint256 _price,
        uint256 _fee,
        bytes _delegateSig,
        uint256 _nonce

    )
    external
    payable
    whenNotPaused
    {
        
        require(_owns(msg.sender, _matronId));
        require(isReadyToMate(_matronId));
        require(canMateWithViaAuction(_matronId, _sireId));

        
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= autoBirthFee);
        require(_price >= currentPrice);

        
        siringAuction.bidDkl(_sireId, _price, _fee, _delegateSig, _nonce);
        if (_incubator == 0 && hasIncubator[msg.sender]) {
            _mateWith(_matronId, _sireId, _incubator);
        } else {
            bytes32 hashedTx = getIncubatorHashing(msg.sender, _incubator, nonces[msg.sender]);
            require(signedBySystem(hashedTx, _incubatorSig));
            nonces[msg.sender]++;

            
            if (!hasIncubator[msg.sender]) {
                hasIncubator[msg.sender] = true;
            }
            _mateWith(_matronId, _sireId, _incubator);
        }
    }

    
    
    
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
        biddingAuction.withdrawBalance();
    }

    function withdrawAuctionDklBalance() external onlyCLevel {
        saleAuction.withdrawDklBalance();
        siringAuction.withdrawDklBalance();
        biddingAuction.withdrawDklBalance();
    }


    function setBiddingRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        biddingAuction.setCut(_prizeCut, _tokenDiscount);
    }

    function setSaleRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        saleAuction.setCut(_prizeCut, _tokenDiscount);
    }

    function setSiringRate(uint256 _prizeCut, uint256 _tokenDiscount) external onlyCLevel {
        siringAuction.setCut(_prizeCut, _tokenDiscount);
    }
}



