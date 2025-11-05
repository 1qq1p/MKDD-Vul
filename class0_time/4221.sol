pragma solidity ^0.4.18;

contract TrueloveAuction is TrueloveDelivery {
	function setDiamondAuctionAddress(address _address) external onlyCEO {
		DiamondAuction candidateContract = DiamondAuction(_address);

		
		require(candidateContract.isDiamondAuction());
		diamondAuction = candidateContract;
	}

	function createDiamondAuction(
		uint256 _tokenId,
		uint256 _startingPrice,
		uint256 _endingPrice,
		uint256 _duration
	)
		external
		whenNotPaused
	{
		require(_owns(msg.sender, _tokenId));
		
		_approve(_tokenId, diamondAuction);
		diamondAuction.createAuction(
			_tokenId,
			_startingPrice,
			_endingPrice,
			_duration,
			msg.sender
		);
	}

	function setFlowerAuctionAddress(address _address) external onlyCEO {
		FlowerAuction candidateContract = FlowerAuction(_address);

		
		require(candidateContract.isFlowerAuction());
		flowerAuction = candidateContract;
	}

	function createFlowerAuction(
		uint256 _amount,
		uint256 _startingPrice,
		uint256 _endingPrice,
		uint256 _duration
	)
		external
		whenNotPaused
	{
		approveFlower(flowerAuction, _amount);
		flowerAuction.createAuction(
			_amount,
			_startingPrice,
			_endingPrice,
			_duration,
			msg.sender
		);
	}

	function withdrawAuctionBalances() external onlyCLevel {
		diamondAuction.withdrawBalance();
		flowerAuction.withdrawBalance();
	}
}
