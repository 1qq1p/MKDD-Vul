pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }






library SafeMath {

	


	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		
		
		
		if (a == 0) {
			return 0;
		}

		c = a * b;
		assert(c / a == b);
		return c;
	}

	


	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		
		
		return a / b;
	}

	


	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	


	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}


interface INameTAOPosition {
	function senderIsAdvocate(address _sender, address _id) external view returns (bool);
	function senderIsListener(address _sender, address _id) external view returns (bool);
	function senderIsSpeaker(address _sender, address _id) external view returns (bool);
	function senderIsPosition(address _sender, address _id) external view returns (bool);
	function getAdvocate(address _id) external view returns (address);
	function nameIsAdvocate(address _nameId, address _id) external view returns (bool);
	function nameIsPosition(address _nameId, address _id) external view returns (bool);
	function initialize(address _id, address _advocateId, address _listenerId, address _speakerId) external returns (bool);
	function determinePosition(address _sender, address _id) external view returns (uint256);
}















contract PathosYotta is TAOCurrency {
	


	constructor(string memory _name, string memory _symbol, address _nameTAOPositionAddress)
		TAOCurrency(_name, _symbol, _nameTAOPositionAddress) public {
		powerOfTen = 24;
		decimals = 24;
	}
}