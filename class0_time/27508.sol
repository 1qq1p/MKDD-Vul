pragma solidity ^0.4.24;




library ArtChainData {
    struct ArtItem {
        uint256 id;
        uint256 price;
        uint256 lastTransPrice;
        address owner;
        uint256 buyYibPrice;
        uint256 buyTime;
        uint256 annualRate;
        uint256 lockDuration;
        bool isExist;
    }

    struct Player {
        uint256 id;     
        address addr;   
        bytes32 name;   
        uint256 laffId;   

        uint256[] ownItemIds;
    }
}

contract ArtChainEvents {
    
    
    
    
    
    
    
    
    

    event onTransferItem
    (
        address from,
        address to,
        uint256 itemId,
        uint256 price,
        uint256 yibPrice,
        uint256 timeStamp
    );
}
