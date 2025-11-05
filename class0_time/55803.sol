

pragma solidity >=0.4.10;


contract Pausable is Owned {
	bool public paused;

	function pause() onlyOwner {
		paused = true;
	}

	function unpause() onlyOwner {
		paused = false;
	}

	modifier notPaused() {
		require(!paused);
		_;
	}
}
