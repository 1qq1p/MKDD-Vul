pragma solidity ^0.5.0;

interface IMultiSigManager {
	function provideAddress(address origin, uint poolIndex) external returns (address payable);
	function passedContract(address) external returns (bool);
	function moderator() external returns(address);
}

interface ICustodianToken {
	function emitTransfer(address from, address to, uint value) external returns (bool success);
}

interface IWETH {
	function balanceOf(address) external returns (uint);
	function transfer(address to, uint value) external returns (bool success);
	function transferFrom(address from, address to, uint value) external returns (bool success);
	function approve(address spender, uint value) external returns (bool success);
	function allowance(address owner, address spender) external returns (uint);
	function withdraw(uint value) external;
	function deposit() external;
}

interface IOracle {
	function getLastPrice() external returns(uint, uint);
	function started() external returns(bool);
}

library SafeMath {
	function mul(uint a, uint b) internal pure returns (uint) {
		uint c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
		
		uint c = a / b;
		
		return c;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
		assert(b <= a);
		return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		assert(c >= a);
		return c;
	}

	function diff(uint a, uint b) internal pure returns (uint) {
		return a > b ? sub(a, b) : sub(b, a);
	}

	function gt(uint a, uint b) internal pure returns(bytes1) {
		bytes1 c;
		c = 0x00;
		if (a > b) {
			c = 0x01;
		}
		return c;
	}
}

contract Beethoven is DualClassCustodian {
	


	
	uint bAdj;

	


	constructor(
		string memory code,
		uint maturity,
		address roleManagerAddr,
		address payable fc,
		uint alpha,
		uint r,
		uint hp,
		uint hu,
		uint hd,
		uint comm,
		uint pd,
		uint optCoolDown,
		uint pxFetchCoolDown,
		uint iteGasTh,
		uint preResetWaitBlk,
		uint minimumBalance
		) 
		public 
		DualClassCustodian ( 
			code,
			maturity,
			roleManagerAddr,
			fc,
			alpha,
			r,
			hp,
			hu,
			hd,
			comm,
			pd,
			optCoolDown,
			pxFetchCoolDown,
			iteGasTh,
			preResetWaitBlk,
			minimumBalance
		)
	{
		bAdj = alphaInBP.add(BP_DENOMINATOR).mul(WEI_DENOMINATOR).div(BP_DENOMINATOR);
	}

	
	function fetchPrice() public inState(State.Trading) returns (bool) {
		uint currentTime = getNowTimestamp();
		require(currentTime > lastPriceTimeInSecond.add(priceFetchCoolDown));
		(uint priceInWei, uint timeInSecond) = oracle.getLastPrice();
		require(timeInSecond > lastPriceTimeInSecond && timeInSecond <= currentTime && priceInWei > 0);
		lastPriceInWei = priceInWei;
		lastPriceTimeInSecond = timeInSecond;
		(navAInWei, navBInWei) = calculateNav(
			priceInWei, 
			timeInSecond, 
			resetPriceInWei, 
			resetPriceTimeInSecond, 
			betaInWei);
		if (maturityInSecond > 0 && timeInSecond > maturityInSecond) {
			state = State.Matured;
			emit Matured(navAInWei, navBInWei);
		} else if (navBInWei >= limitUpperInWei || navBInWei <= limitLowerInWei || (limitPeriodicInWei > 0 && navAInWei >= limitPeriodicInWei)) {
			state = State.PreReset;
			lastPreResetBlockNo = block.number;
			emit StartPreReset();
		} 
		emit AcceptPrice(priceInWei, timeInSecond, navAInWei, navBInWei);
		return true;
	}
	
	function calculateNav(
		uint priceInWei, 
		uint timeInSecond, 
		uint rstPriceInWei, 
		uint rstTimeInSecond,
		uint bInWei) 
		internal 
		view 
		returns (uint, uint) 
	{
		uint numOfPeriods = timeInSecond.sub(rstTimeInSecond).div(period);
		uint navParent = priceInWei.mul(WEI_DENOMINATOR).div(rstPriceInWei);
		navParent = navParent
			.mul(WEI_DENOMINATOR)
			.mul(alphaInBP.add(BP_DENOMINATOR))
			.div(BP_DENOMINATOR)
			.div(bInWei
		);
		uint navA = periodCouponInWei.mul(numOfPeriods).add(WEI_DENOMINATOR);
		uint navAAdj = navA.mul(alphaInBP).div(BP_DENOMINATOR);
		if (navParent <= navAAdj)
			return (navParent.mul(BP_DENOMINATOR).div(alphaInBP), 0);
		else
			return (navA, navParent.sub(navAAdj));
	}
	

	
	function startPreReset() public inState(State.PreReset) returns (bool success) {
		if (block.number - lastPreResetBlockNo >= preResetWaitingBlocks) {
			uint newBFromA;
			uint newAFromA;
			if (navBInWei >= limitUpperInWei) {
				state = State.Reset;
				resetState = ResetState.UpwardReset;
				betaInWei = WEI_DENOMINATOR;
				uint excessAInWei = navAInWei.sub(WEI_DENOMINATOR);
				uint excessBInWei = navBInWei.sub(WEI_DENOMINATOR);
				
				
				uint excessBAfterAInWei = excessBInWei.sub(excessAInWei);
				newAFromAPerA = excessAInWei;
				newBFromAPerA = 0;
				uint newBFromExcessBPerB = excessBAfterAInWei.mul(betaInWei).div(bAdj);
				newAFromBPerB = newBFromExcessBPerB.mul(alphaInBP).div(BP_DENOMINATOR);
				newBFromBPerB = excessAInWei.add(newBFromExcessBPerB);			
				
				
				







				
				totalSupplyA = totalSupplyA
					.add(totalSupplyA
						.mul(newAFromAPerA)
						.add(totalSupplyB
							.mul(newAFromBPerB))
						.div(WEI_DENOMINATOR)
				);
				totalSupplyB = totalSupplyB
					.add(totalSupplyA
						.mul(newBFromAPerA)
						.add(totalSupplyB
							.mul(newBFromBPerB))
						.div(WEI_DENOMINATOR)
				);
			} else if (navBInWei <= limitLowerInWei) {
				state = State.Reset;
				resetState = ResetState.DownwardReset;
				betaInWei = WEI_DENOMINATOR;
				newBFromAPerA = navAInWei.sub(navBInWei).mul(betaInWei).div(bAdj);
				
				newAFromAPerA = 0;
				newBFromBPerB = 0;
				newAFromBPerB = 0;
				
				newBFromA = totalSupplyA.mul(newBFromAPerA).div(WEI_DENOMINATOR);
				newAFromA = newBFromA.mul(alphaInBP).div(BP_DENOMINATOR);
				totalSupplyA = totalSupplyA.mul(navBInWei).div(WEI_DENOMINATOR).add(newAFromA);
				totalSupplyB = totalSupplyB.mul(navBInWei).div(WEI_DENOMINATOR).add(newBFromA);
			} else { 
				state = State.Reset;
				resetState = ResetState.PeriodicReset;
				uint num = alphaInBP
					.add(BP_DENOMINATOR)
					.mul(lastPriceInWei);
				uint den = num
					.sub(
						resetPriceInWei
							.mul(alphaInBP)
							.mul(betaInWei)
							.mul(navAInWei
								.sub(WEI_DENOMINATOR))
							.div(WEI_DENOMINATOR)
							.div(WEI_DENOMINATOR)
				);
				betaInWei = betaInWei.mul(num).div(den);
				newBFromAPerA = navAInWei.sub(WEI_DENOMINATOR).mul(betaInWei).div(bAdj);
				
				newBFromBPerB = 0;
				newAFromAPerA = 0;
				newAFromBPerB = 0;
				
				newBFromA = totalSupplyA.mul(newBFromAPerA).div(WEI_DENOMINATOR);
				newAFromA = newBFromA.mul(alphaInBP).div(BP_DENOMINATOR);
				totalSupplyA = totalSupplyA.add(newAFromA);
				totalSupplyB = totalSupplyB.add(newBFromA);
			}

			emit TotalSupply(totalSupplyA, totalSupplyB);

			emit StartReset(nextResetAddrIndex, users.length);
		} else 
			emit StartPreReset();

		return true;
	}

	function startReset() public inState(State.Reset) returns (bool success) {
		uint currentBalanceA;
		uint currentBalanceB;
		uint newBalanceA;
		uint newBalanceB;
		uint newAFromA;
		uint newBFromA;
		address currentAddress;
		uint localResetAddrIndex = nextResetAddrIndex;
		while (localResetAddrIndex < users.length && gasleft() > iterationGasThreshold) {
			currentAddress = users[localResetAddrIndex];
			currentBalanceA = balanceOf[0][currentAddress];
			currentBalanceB = balanceOf[1][currentAddress];
			if (resetState == ResetState.DownwardReset) {
				newBFromA = currentBalanceA.mul(newBFromAPerA).div(WEI_DENOMINATOR);
				newAFromA = newBFromA.mul(alphaInBP).div(BP_DENOMINATOR);
				newBalanceA = currentBalanceA.mul(navBInWei).div(WEI_DENOMINATOR).add(newAFromA);
				newBalanceB = currentBalanceB.mul(navBInWei).div(WEI_DENOMINATOR).add(newBFromA);
			}
			else if (resetState == ResetState.UpwardReset) {
				newBalanceA = currentBalanceA
					.add(currentBalanceA
						.mul(newAFromAPerA)
						.add(currentBalanceB
							.mul(newAFromBPerB))
						.div(WEI_DENOMINATOR)
				);
				newBalanceB = currentBalanceB
					.add(currentBalanceA
						.mul(newBFromAPerA)
						.add(currentBalanceB
							.mul(newBFromBPerB))
						.div(WEI_DENOMINATOR)
				);
			} else {
				newBFromA = currentBalanceA.mul(newBFromAPerA).div(WEI_DENOMINATOR);
				newAFromA = newBFromA.mul(alphaInBP).div(BP_DENOMINATOR);
				newBalanceA = currentBalanceA.add(newAFromA);
				newBalanceB = currentBalanceB.add(newBFromA);
			}

			balanceOf[0][currentAddress] = newBalanceA;
			balanceOf[1][currentAddress] = newBalanceB;
			localResetAddrIndex++;
		}

		if (localResetAddrIndex >= users.length) {
			if (resetState != ResetState.PeriodicReset) {
				resetPriceInWei = lastPriceInWei;
				navBInWei = WEI_DENOMINATOR;
			}
			resetPriceTimeInSecond = lastPriceTimeInSecond;
			
			navAInWei = WEI_DENOMINATOR;
			nextResetAddrIndex = 0;

			state = State.Trading;
			emit StartTrading(navAInWei, navBInWei);
			return true;
		} else {
			nextResetAddrIndex = localResetAddrIndex;
			emit StartReset(localResetAddrIndex, users.length);
			return false;
		}
	}
	
}