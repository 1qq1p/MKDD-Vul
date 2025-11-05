pragma solidity ^0.4.19;



contract BdpController is BdpBase {

	function name() external pure returns (string) {
		return "CryptoPicture Block";
	}

	function tokenURI(uint256 _tokenId) external view returns (string _tokenURI) {
		_tokenURI = "https://cryptopicture.com/#0000000";
		bytes memory tokenURIBytes = bytes(_tokenURI);
		tokenURIBytes[27] = byte(48+(_tokenId / 1000000) % 10);
		tokenURIBytes[28] = byte(48+(_tokenId / 100000) % 10);
		tokenURIBytes[29] = byte(48+(_tokenId / 10000) % 10);
		tokenURIBytes[30] = byte(48+(_tokenId / 1000) % 10);
		tokenURIBytes[31] = byte(48+(_tokenId / 100) % 10);
		tokenURIBytes[32] = byte(48+(_tokenId / 10) % 10);
		tokenURIBytes[33] = byte(48+(_tokenId / 1) % 10);
	}


	

	function createRegion(uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2) public onlyAuthorized returns (uint256) {
		BdpCrud.createRegion(contracts, ownerAddress, _x1, _y1, _x2, _y2);
	}

	function deleteRegion(uint256 _regionId) public onlyAuthorized returns (uint256) {
		BdpCrud.deleteRegion(contracts, _regionId);
	}

	function setupRegion(uint256 _regionId, uint256 _imageId, uint256[] _imageData, bool _swapImages, uint8[128] _url) whileContractIsActive public {
		BdpCrud.setupRegion(contracts, _regionId, _imageId, _imageData, _swapImages, _url);
	}

	function updateRegion(uint256 _regionId, uint256 _imageId, uint256[] _imageData, bool _swapImages, bool _clearImage, uint8[128] _url, bool _deleteUrl, address _newOwner) whileContractIsActive public payable {
		BdpCrud.updateRegion(contracts, _regionId, _imageId, _imageData, _swapImages, _clearImage, _url, _deleteUrl, _newOwner);
	}

	function updateRegionPixelPrice(uint256 _regionId, uint256 _pixelPrice) whileContractIsActive public payable {
		BdpCrud.updateRegionPixelPrice(contracts, _regionId, _pixelPrice);
	}


	

	function checkImageInput(uint256 _regionId, uint256 _imageId, uint256[] _imageData, bool _swapImages, bool _clearImage) view public {
		BdpImage.checkImageInput(contracts, _regionId, _imageId, _imageData, _swapImages, _clearImage);
	}

	function setNextImagePart(uint256 _regionId, uint16 _part, uint16 _partsCount, uint16 _imageDescriptor, uint256[] _imageData) whileContractIsActive public {
		BdpImage.setNextImagePart(contracts, _regionId, _part, _partsCount, _imageDescriptor, _imageData);
	}


	

	function ownerOf(uint256 _tokenId) external view returns (address _owner) {
		return BdpOwnership.ownerOf(contracts, _tokenId);
	}

	function totalSupply() external view returns (uint256 _count) {
		return BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(contracts)).getTokenIdsLength();
	}

	function balanceOf(address _owner) external view returns (uint256 _count) {
		return BdpOwnership.balanceOf(contracts, _owner);
	}

	function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
		return BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(contracts)).getOwnedToken(_owner, _index);
	}

	function tokenByIndex(uint256 _index) external view returns (uint256) {
		return BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(contracts)).getTokenIdByIndex(_index);
	}

	function getOwnedArea(address _owner) public view returns (uint256) {
		return BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(contracts)).getOwnedArea(_owner);
	}


	

	function purchase(uint256 _regionId) whileContractIsActive external payable {
		BdpTransfer.purchase(contracts, _regionId);
	}


	

	function withdrawBalance() external onlyOwner {
		ownerAddress.transfer(this.balance);
	}


	

	function () public {
		address _impl = BdpContracts.getBdpControllerHelper(contracts);
		require(_impl != address(0));
		bytes memory data = msg.data;

		assembly {
			let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
			let size := returndatasize
			let ptr := mload(0x40)
			returndatacopy(ptr, 0, size)
			switch result
			case 0 { revert(ptr, size) }
			default { return(ptr, size) }
		}
	}

	function BdpController(bytes8 _version) public {
		ownerAddress = msg.sender;
		managerAddress = msg.sender;
		version = _version;
	}

}