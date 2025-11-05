pragma solidity ^0.4.18;

contract TrueloveFlowerOwnership is TrueloveBase, EIP20Interface {
	uint256 constant private MAX_UINT256 = 2**256 - 1;
	mapping (address => mapping (address => uint256)) public flowerAllowed;

	bytes4 constant EIP20InterfaceSignature = bytes4(0x98474109);
		
		
		
		

	function supportsEIP20Interface(bytes4 _interfaceID) external view returns (bool) {
		return _interfaceID == EIP20InterfaceSignature;
	}

	function _transferFlower(address _from, address _to, uint256 _value) internal returns (bool success) {
		if (_from != address(0)) {
			require(flowerBalances[_from] >= _value);
			flowerBalances[_from] -= _value;
		}
		flowerBalances[_to] += _value;
		TransferFlower(_from, _to, _value);
		return true;
	}

	function transferFlower(address _to, uint256 _value) public returns (bool success) {
		require(flowerBalances[msg.sender] >= _value);
		flowerBalances[msg.sender] -= _value;
		flowerBalances[_to] += _value;
		TransferFlower(msg.sender, _to, _value);
		return true;
	}

	function transferFromFlower(address _from, address _to, uint256 _value) public returns (bool success) {
		uint256 allowance = flowerAllowed[_from][msg.sender];
		require(flowerBalances[_from] >= _value && allowance >= _value);
		flowerBalances[_to] += _value;
		flowerBalances[_from] -= _value;
		if (allowance < MAX_UINT256) {
			flowerAllowed[_from][msg.sender] -= _value;
		}
		TransferFlower(_from, _to, _value);
		return true;
	}

	function balanceOfFlower(address _owner) public view returns (uint256 balance) {
		return flowerBalances[_owner];
	}

	function approveFlower(address _spender, uint256 _value) public returns (bool success) {
		flowerAllowed[msg.sender][_spender] = _value;
		ApprovalFlower(msg.sender, _spender, _value);
		return true;
	}

	function allowanceFlower(address _owner, address _spender) public view returns (uint256 remaining) {
		return flowerAllowed[_owner][_spender];
	}

	function _addFlower(uint256 _amount) internal {
		flower.current += _amount;
		flowerTotalSupply += _amount;
	}
}
