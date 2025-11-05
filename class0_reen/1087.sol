
pragma solidity >=0.4.10;

contract Token is Finalizable, TokenReceivable, SafeMath, EventDefinitions, Pausable {
	string constant public name = "Education";
	uint8 constant public decimals = 8;
	string constant public symbol = "EDU";
	Controller public controller;
	string public motd;
	event Motd(string message);

	

	function setMotd(string _m) onlyOwner {
		motd = _m;
		Motd(_m);
	}

	function setController(address _c) onlyOwner notFinalized {
		controller = Controller(_c);
	}

	

	function balanceOf(address a) constant returns (uint) {
		return controller.balanceOf(a);
	}

	function totalSupply() constant returns (uint) {
		return controller.totalSupply();
	}

	function allowance(address _owner, address _spender) constant returns (uint) {
		return controller.allowance(_owner, _spender);
	}

	function transfer(address _to, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
		if (controller.transfer(msg.sender, _to, _value)) {
			Transfer(msg.sender, _to, _value);
			return true;
		}
		return false;
	}

	function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3) notPaused returns (bool success) {
		if (controller.transferFrom(msg.sender, _from, _to, _value)) {
			Transfer(_from, _to, _value);
			return true;
		}
		return false;
	}

	function approve(address _spender, uint _value) onlyPayloadSize(2) notPaused returns (bool success) {
		if (controller.approve(msg.sender, _spender, _value)) {
			Approval(msg.sender, _spender, _value);
			return true;
		}
		return false;
	}

	function increaseApproval (address _spender, uint _addedValue) onlyPayloadSize(2) notPaused returns (bool success) {
		if (controller.increaseApproval(msg.sender, _spender, _addedValue)) {
			uint newval = controller.allowance(msg.sender, _spender);
			Approval(msg.sender, _spender, newval);
			return true;
		}
		return false;
	}

	function decreaseApproval (address _spender, uint _subtractedValue) onlyPayloadSize(2) notPaused returns (bool success) {
		if (controller.decreaseApproval(msg.sender, _spender, _subtractedValue)) {
			uint newval = controller.allowance(msg.sender, _spender);
			Approval(msg.sender, _spender, newval);
			return true;
		}
		return false;
	}

	modifier onlyPayloadSize(uint numwords) {
		assert(msg.data.length >= numwords * 32 + 4);
		_;
	}

	function burn(uint _amount) notPaused {
		controller.burn(msg.sender, _amount);
		Transfer(msg.sender, 0x0, _amount);
	}

	

	modifier onlyController() {
		assert(msg.sender == address(controller));
		_;
	}

	function controllerTransfer(address _from, address _to, uint _value) onlyController {
		Transfer(_from, _to, _value);
	}

	function controllerApprove(address _owner, address _spender, uint _value) onlyController {
		Approval(_owner, _spender, _value);
	}
}
