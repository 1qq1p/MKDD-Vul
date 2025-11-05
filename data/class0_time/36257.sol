pragma solidity ^0.4.18;





contract Whitelist is Secured {
	mapping(address => bool) whitelist;
	event WhitelistChange(address indexed addr, bool allow);

	function isInWhitelist(address addr) constant public returns (bool) {
		return whitelist[addr];
	}

	function setWhitelist(address addr, bool allow) only("operator") public {
		setWhitelistInternal(addr, allow);
	}

	function setWhitelistInternal(address addr, bool allow) internal {
		whitelist[addr] = allow;
		WhitelistChange(addr, allow);
	}
}
