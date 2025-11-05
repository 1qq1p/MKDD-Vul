pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }


contract Ethos is TAOCurrency {
	


	constructor(string memory _name, string memory _symbol, address _nameTAOPositionAddress)
		TAOCurrency(_name, _symbol, _nameTAOPositionAddress) public {}
}











