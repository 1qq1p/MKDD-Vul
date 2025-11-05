

pragma solidity ^0.4.21;

library IexecLib
{
	
	
	
	enum MarketOrderDirectionEnum
	{
		UNSET,
		BID,
		ASK,
		CLOSED
	}
	struct MarketOrder
	{
		MarketOrderDirectionEnum direction;
		uint256 category;        
		uint256 trust;           
		uint256 value;           
		uint256 volume;          
		uint256 remaining;       
		address workerpool;      
		address workerpoolOwner; 
	}

	
	
	
	enum WorkOrderStatusEnum
	{
		UNSET,     
		ACTIVE,    
		REVEALING, 
		CLAIMED,   
		COMPLETED  
	}

	
	
	
	
	
	struct Consensus
	{
		uint256 poolReward;
		uint256 stakeAmount;
		bytes32 consensus;
		uint256 revealDate;
		uint256 revealCounter;
		uint256 consensusTimeout;
		uint256 winnerCount;
		address[] contributors;
		address workerpoolOwner;
		uint256 schedulerRewardRatioPolicy;

	}

	
	
	
	
	
	enum ContributionStatusEnum
	{
		UNSET,
		AUTHORIZED,
		CONTRIBUTED,
		PROVED,
		REJECTED
	}
	struct Contribution
	{
		ContributionStatusEnum status;
		bytes32 resultHash;
		bytes32 resultSign;
		address enclaveChallenge;
		uint256 score;
		uint256 weight;
	}

	
	
	
	
	
	struct Account
	{
		uint256 stake;
		uint256 locked;
	}

	struct ContributionHistory 
	{
		uint256 success;
		uint256 failed;
	}

	struct Category
	{
		uint256 catid;
		string  name;
		string  description;
		uint256 workClockTimeRef;
	}

}


pragma solidity ^0.4.8;

contract IexecHubAccessor
{
	IexecHubInterface internal iexecHubInterface;

	modifier onlyIexecHub()
	{
		require(msg.sender == address(iexecHubInterface));
		_;
	}

	function IexecHubAccessor(address _iexecHubAddress) public
	{
		require(_iexecHubAddress != address(0));
		iexecHubInterface = IexecHubInterface(_iexecHubAddress);
	}

}


pragma solidity ^0.4.21;
