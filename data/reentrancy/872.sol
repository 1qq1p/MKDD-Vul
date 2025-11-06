






pragma solidity ^0.4.21;

contract CasinoBank is ChargingGas {
	
	uint public playerBalance;
	
	mapping(address => uint) public balanceOf;
	
	mapping(address => uint) public withdrawAfter;
	
	mapping(address => uint) public withdrawCount;
	
	uint public maxDeposit;
	
	uint public maxWithdrawal;
	
	uint public waitingTime;
	
	address public predecessor;

	
	event Deposit(address _player, uint _numTokens, uint _gasCost);
	
	event Withdrawal(address _player, address _receiver, uint _numTokens, uint _gasCost);
	
	
	




	function CasinoBank(uint depositLimit, address predecessorAddr) internal {
		maxDeposit = depositLimit * oneEDG;
		maxWithdrawal = maxDeposit;
		waitingTime = 24 hours;
		predecessor = predecessorAddr;
	}

	







	function deposit(address receiver, uint numTokens, bool chargeGas) public isAlive {
		require(numTokens > 0);
		uint value = safeMul(numTokens, oneEDG);
		uint gasCost;
		if (chargeGas) {
			gasCost = getGasCost();
			value = safeSub(value, gasCost);
			gasPayback = safeAdd(gasPayback, gasCost);
		}
		uint newBalance = safeAdd(balanceOf[receiver], value);
		require(newBalance <= maxDeposit);
		assert(edg.transferFrom(msg.sender, address(this), numTokens));
		balanceOf[receiver] = newBalance;
		playerBalance = safeAdd(playerBalance, value);
		emit Deposit(receiver, numTokens, gasCost);
	}

	




	function requestWithdrawal() public {
		withdrawAfter[msg.sender] = now + waitingTime;
	}

	



	function cancelWithdrawalRequest() public {
		withdrawAfter[msg.sender] = 0;
	}

	



	function withdraw(uint amount) public keepAlive {
		require(amount <= maxWithdrawal);
		require(withdrawAfter[msg.sender] > 0 && now > withdrawAfter[msg.sender]);
		withdrawAfter[msg.sender] = 0;
		uint value = safeMul(amount, oneEDG);
		balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], value);
		playerBalance = safeSub(playerBalance, value);
		assert(edg.transfer(msg.sender, amount));
		emit Withdrawal(msg.sender, msg.sender, amount, 0);
	}

	




	function withdrawBankroll(address receiver, uint numTokens) public onlyAuthorized {
		require(numTokens <= bankroll());
		require(allowedReceiver[receiver]);
		assert(edg.transfer(receiver, numTokens));
	}

	


	function withdrawGasPayback() public onlyAuthorized {
		uint payback = gasPayback / oneEDG;
		assert(payback > 0);
		gasPayback = safeSub(gasPayback, payback * oneEDG);
		assert(edg.transfer(owner, payback));
	}

	


	function bankroll() view public returns(uint) {
		return safeSub(edg.balanceOf(address(this)), safeAdd(playerBalance, gasPayback) / oneEDG);
	}


	



	function setMaxDeposit(uint newMax) public onlyAuthorized {
		maxDeposit = newMax * oneEDG;
	}
	
	



	function setMaxWithdrawal(uint newMax) public onlyAuthorized {
		maxWithdrawal = newMax * oneEDG;
	}

	




	function setWaitingTime(uint newWaitingTime) public onlyAuthorized  {
		require(newWaitingTime <= 24 hours);
		waitingTime = newWaitingTime;
	}

	





	function withdrawFor(address receiver, uint amount, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized keepAlive {
		address player = ecrecover(keccak256(receiver, amount, withdrawCount[receiver]), v, r, s);
		withdrawCount[receiver]++;
		uint gasCost = getGasCost();
		uint value = safeAdd(safeMul(amount, oneEDG), gasCost);
		gasPayback = safeAdd(gasPayback, gasCost);
		balanceOf[player] = safeSub(balanceOf[player], value);
		playerBalance = safeSub(playerBalance, value);
		assert(edg.transfer(receiver, amount));
		emit Withdrawal(player, receiver, amount, gasCost);
	}
	
	





	function transferToNewContract(address newCasino, uint8 v, bytes32 r, bytes32 s, bool chargeGas) public onlyAuthorized keepAlive {
		address player = ecrecover(keccak256(address(this), newCasino), v, r, s);
		uint gasCost = 0;
		if(chargeGas) gasCost = getGasCost();
		uint value = safeSub(balanceOf[player], gasCost);
		require(value > oneEDG);
		
		value /= oneEDG;
		playerBalance = safeSub(playerBalance, balanceOf[player]);
		balanceOf[player] = 0;
		assert(edg.transfer(newCasino, value));
		emit Withdrawal(player, newCasino, value, gasCost);
		CasinoBank cb = CasinoBank(newCasino);
		assert(cb.credit(player, value));
	}
	
	




	function credit(address player, uint value) public returns(bool) {
		require(msg.sender == predecessor);
		uint valueWithDecimals = safeMul(value, oneEDG);
		balanceOf[player] = safeAdd(balanceOf[player], valueWithDecimals);
		playerBalance = safeAdd(playerBalance, valueWithDecimals);
		emit Deposit(player, value, 0);
		return true;
	}

	


	function close() public onlyOwner {
		closeContract(playerBalance);
	}
}

