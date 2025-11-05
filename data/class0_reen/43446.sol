pragma solidity ^0.4.24;








contract MEH is MehERC721, Accounting {

    
    event LogBuys(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        address newLandlord
    );

    
    event LogSells(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint sellPrice
    );

    
    event LogRentsOut(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint rentPricePerPeriodWei
    );

    
    event LogRents(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint numberOfPeriods,
        uint rentedFrom
    );

    
    event LogAds(
        uint ID, 
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        string imageSourceUrl,
        string adUrl,
        string adText,
        address indexed advertiser);


    
    
    
    
    
    function buyArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) 
        external
        whenNotPaused
        payable
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));
        require(canPay(areaPrice(fromX, fromY, toX, toY)));
        depositFunds();

        
        
        uint id = market.buyBlocks(msg.sender, blocksList(fromX, fromY, toX, toY));
        emit LogBuys(id, fromX, fromY, toX, toY, msg.sender);
    }

    
    
    function sellArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint priceForEachBlockWei)
        external 
        whenNotPaused
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        
        uint id = market.sellBlocks(
            msg.sender, 
            priceForEachBlockWei, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogSells(id, fromX, fromY, toX, toY, priceForEachBlockWei);
    }

    
    function areaPrice(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) 
        public 
        view 
        returns (uint) 
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        return market.areaPrice(blocksList(fromX, fromY, toX, toY));
    }


        
    
    
    
    function rentOutArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint rentPricePerPeriodWei)
        external
        whenNotPaused
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        
        uint id = rentals.rentOutBlocks(
            msg.sender, 
            rentPricePerPeriodWei, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogRentsOut(id, fromX, fromY, toX, toY, rentPricePerPeriodWei);
    }
    
    
    
    
    function rentArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint numberOfPeriods)
        external
        payable
        whenNotPaused
    {   
        
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));
        require(canPay(areaRentPrice(fromX, fromY, toX, toY, numberOfPeriods)));
        depositFunds();

        
        
        uint id = rentals.rentBlocks(
            msg.sender, 
            numberOfPeriods, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogRents(id, fromX, fromY, toX, toY, numberOfPeriods, 0);
    }

    
    
    function areaRentPrice(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint numberOfPeriods)
        public 
        view 
        returns (uint) 
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        return rentals.blocksRentPrice (numberOfPeriods, blocksList(fromX, fromY, toX, toY));
    }


    
    
    
    
    
    function placeAds( 
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY, 
        string imageSource, 
        string link, 
        string text
    ) 
        external
        whenNotPaused
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        
        uint AdsId = ads.advertiseOnBlocks(
            msg.sender, 
            blocksList(fromX, fromY, toX, toY), 
            imageSource, 
            link, 
            text
        );
        emit LogAds(AdsId, fromX, fromY, toX, toY, imageSource, link, text, msg.sender);
    }

    
    
    function canAdvertise(
        address advertiser,
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        external
        view
        returns (bool)
    {   
        
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        
        return ads.canAdvertiseOnBlocks(advertiser, blocksList(fromX, fromY, toX, toY));
    }



    
    function adminImportOldMEBlock(uint8 x, uint8 y) external onlyOwner {
        (uint id, address newLandlord) = market.importOldMEBlock(x, y);
        emit LogBuys(id, x, y, x, y, newLandlord);
    }


    
    
    function getBlockOwner(uint8 x, uint8 y) external view returns (address) {
        return ownerOf(blockID(x, y));
    }


    
    
    function blockID(uint8 x, uint8 y) public pure returns (uint16) {
        return (uint16(y) - 1) * 100 + uint16(x);
    }

    
    function countBlocks(
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        internal 
        pure 
        returns (uint16)
    {
        return (toX - fromX + 1) * (toY - fromY + 1);
    }

    
    function blocksList(
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        internal 
        pure 
        returns (uint16[] memory r) 
    {
        uint i = 0;
        r = new uint16[](countBlocks(fromX, fromY, toX, toY));
        for (uint8 ix=fromX; ix<=toX; ix++) {
            for (uint8 iy=fromY; iy<=toY; iy++) {
                r[i] = blockID(ix, iy);
                i++;
            }
        }
    }
    
    
    
    
    
    function isLegalCoordinates(
        uint8 _fromX, 
        uint8 _fromY, 
        uint8 _toX, 
        uint8 _toY
    )    
        private 
        pure 
        returns (bool) 
    {
        return ((_fromX >= 1) && (_fromY >=1)  && (_toX <= 100) && (_toY <= 100) 
            && (_fromX <= _toX) && (_fromY <= _toY));
    }
}




