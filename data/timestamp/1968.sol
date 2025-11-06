pragma solidity ^0.4.11;

contract DeDeContract {

	address public masterContract;

	function DeDeContract(address targetAddress, uint256 targetAmount) payable {
		masterContract = msg.sender;
		if(targetAddress != 0){
			assert(ERC20Interface(targetAddress).approve(msg.sender, targetAmount));
		}
	}

	function activate(address destination) payable {
		require(msg.sender == masterContract);

		suicide(destination);
	}
	function nullify(address destination) {
		require(msg.sender == masterContract);

		suicide(destination);
	}
}