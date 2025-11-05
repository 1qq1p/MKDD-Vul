pragma solidity ^0.4.16;

pragma solidity ^0.4.16;

contract Permissions {

	address ownerAddress;
	address storageAddress;
	address callerAddress;

	function Permissions() public {
		ownerAddress = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == ownerAddress);
		_;
	}

	modifier onlyCaller() {
		require(msg.sender == callerAddress);
		_;
	}

	function getOwner() view external returns (address) {
		return ownerAddress;
	}

	function getStorageAddress() view external returns (address) {
		return storageAddress;
	}

	function getCaller() view external returns (address) {
		return callerAddress;
	}

	function transferOwnership(address newOwner) external onlyOwner {
		if (newOwner != address(0)) {
				ownerAddress = newOwner;
		}
	}
	function newStorage(address _new) external onlyOwner {
		if (_new != address(0)) {
				storageAddress = _new;
		}
	}
	function newCaller(address _new) external onlyOwner {
		if (_new != address(0)) {
				callerAddress = _new;
		}
	}
}
