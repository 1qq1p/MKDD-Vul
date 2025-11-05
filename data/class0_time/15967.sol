







pragma solidity ^0.4.15;

contract Reservation is mortal, SafeMath {
	ICO public ico;
	address[] public investors;
	mapping(address => uint) public balanceOf;
	mapping(address => bool) invested;


	
	function Reservation(address _icoAddr) {
		ico = ICO(_icoAddr);
	}

	
	function() payable {
		if (msg.value > 0) {
			if (!invested[msg.sender]) {
				investors.push(msg.sender);
				invested[msg.sender] = true;
			}
			balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], msg.value);
		}
	}



	


	function buyTokens(uint _from, uint _to) onlyOwner {
		require(address(ico)!=0x0);
		uint amount;
		if (_to > investors.length)
			_to = investors.length;
		for (uint i = _from; i < _to; i++) {
			if (balanceOf[investors[i]] > 0) {
				amount = balanceOf[investors[i]];
				delete balanceOf[investors[i]];
				ico.invest.value(amount)(investors[i]);
			}
		}
	}

	

	function withdraw() {
		uint amount = balanceOf[msg.sender];
		require(amount > 0);
		
		balanceOf[msg.sender] = 0;
		msg.sender.transfer(amount);
	}

	
	function getNumInvestors() constant returns(uint) {
		return investors.length;
	}
	
	function setICO(address _icoAddr) onlyOwner {
		ico = ICO(_icoAddr);
	}

}