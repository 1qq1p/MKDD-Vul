pragma solidity ^0.4.16;

contract KelevinKoin is Owned, MifflinToken {
    
    function KelevinKoin(address exchange)
	MifflinToken(exchange, 5, 69000000, "Kelevin Koin", "KLEV", 8) public {
        buyPrice = weiRate / ethDolRate / uint(10) ** decimals / 50; 
    }

    function () payable public {
        contribution(msg.value);
        
        uint256 lastBlockHash = uint256(keccak256(block.blockhash(block.number - 1), uint8(0)));
        uint256 newPrice = buyPrice + ((lastBlockHash % (buyPrice * 69 / 1000)) - (buyPrice * 69 * 2 / 1000));
        buyPrice = newPrice;
        uint256 amountToGive = msg.value / buyPrice;
        if (buyPrice % msg.value == 0)
			amountToGive += amountToGive * 69 / 1000; 
        buy(amountToGive);
    }
}

