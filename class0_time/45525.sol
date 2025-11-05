pragma solidity ^0.4.24;




interface SpinWinInterface {
	function refundPendingBets() external returns (bool);
}





interface AdvertisingInterface {
	function incrementBetCounter() external returns (bool);
}


contract SpinWinLibraryInterface {
	function calculateWinningReward(uint256 betValue, uint256 playerNumber, uint256 houseEdge) external pure returns (uint256);
	function calculateTokenReward(address settingAddress, uint256 betValue, uint256 playerNumber, uint256 houseEdge) external constant returns (uint256);
	function generateRandomNumber(address settingAddress, uint256 betBlockNumber, uint256 extraData, uint256 divisor) external constant returns (uint256);
	function calculateClearBetBlocksReward(address settingAddress, address lotteryAddress) external constant returns (uint256);
	function calculateLotteryContribution(address settingAddress, address lotteryAddress, uint256 betValue) external constant returns (uint256);
	function calculateExchangeTokenValue(address settingAddress, uint256 tokenAmount) external constant returns (uint256, uint256, uint256, uint256);
}





interface LotteryInterface {
	function claimReward(address playerAddress, uint256 tokenAmount) external returns (bool);
	function calculateLotteryContributionPercentage() external constant returns (uint256);
	function getNumLottery() external constant returns (uint256);
	function isActive() external constant returns (bool);
	function getCurrentTicketMultiplierHonor() external constant returns (uint256);
	function getCurrentLotteryTargetBalance() external constant returns (uint256, uint256);
}





interface SettingInterface {
	function uintSettings(bytes32 name) external constant returns (uint256);
	function boolSettings(bytes32 name) external constant returns (bool);
	function isActive() external constant returns (bool);
	function canBet(uint256 rewardValue, uint256 betValue, uint256 playerNumber, uint256 houseEdge) external constant returns (bool);
	function isExchangeAllowed(address playerAddress, uint256 tokenAmount) external constant returns (bool);

	
	
	
	function spinwinSetUintSetting(bytes32 name, uint256 value) external;
	function spinwinIncrementUintSetting(bytes32 name) external;
	function spinwinSetBoolSetting(bytes32 name, bool value) external;
	function spinwinAddFunds(uint256 amount) external;
	function spinwinUpdateTokenToWeiExchangeRate() external;
	function spinwinRollDice(uint256 betValue) external;
	function spinwinUpdateWinMetric(uint256 playerProfit) external;
	function spinwinUpdateLoseMetric(uint256 betValue, uint256 tokenRewardValue) external;
	function spinwinUpdateLotteryContributionMetric(uint256 lotteryContribution) external;
	function spinwinUpdateExchangeMetric(uint256 exchangeAmount) external;

	
	
	
	function spinlotterySetUintSetting(bytes32 name, uint256 value) external;
	function spinlotteryIncrementUintSetting(bytes32 name) external;
	function spinlotterySetBoolSetting(bytes32 name, bool value) external;
	function spinlotteryUpdateTokenToWeiExchangeRate() external;
	function spinlotterySetMinBankroll(uint256 _minBankroll) external returns (bool);
}





interface TokenInterface {
	function getTotalSupply() external constant returns (uint256);
	function getBalanceOf(address account) external constant returns (uint256);
	function transfer(address _to, uint256 _value) external returns (bool);
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
	function approve(address _spender, uint256 _value) external returns (bool success);
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool success);
	function burn(uint256 _value) external returns (bool success);
	function burnFrom(address _from, uint256 _value) external returns (bool success);
	function mintTransfer(address _to, uint _value) external returns (bool);
	function burnAt(address _at, uint _value) external returns (bool);
}










library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		uint256 c = a / b;
		
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
