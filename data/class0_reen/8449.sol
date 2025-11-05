pragma solidity ^0.4.18;









contract AumICO is usingOraclize, SafeMath {
	
	
	
	
	
	struct OperationInQueue
	{
		uint operationStartTime;
		uint depositedEther;
		address receiver;
		bool closed;
	}
	
	struct Contact
	{
		uint obtainedTokens;
		uint depositedEther;
		bool isOnWhitelist;
		bool userExists;
		bool userLiquidated;
		uint depositedLEX;
	}
	
	uint[3] public tokenPrice;
	uint[3] public availableTokens;
	uint public tokenCurrentStage;
	bool public hasICOFinished;
	
	uint public etherPrice; 
	uint public etherInContract;
	uint public LEXInContract;
	uint public usdEstimateInContract; 
	uint public softCap = 35437500000000000; 
	uint currentSoftCapContact;
	
	uint public startEpochTimestamp = 1518807600; 
	uint public endEpochTimestamp = 1521093600; 
	
	uint public lastPriceCheck = 0;
	
	uint preICOAvailableTokens = 11250000; 
	uint ICOAvailableTokens = 20625000; 
	
	uint minAmmountToInvest = 100000000000000000; 
	uint maxAmmountToInvest = 500000000000000000000; 
	
	address LEXTokenAddress; 
	address tokenContractAddress;
	address tokenVaultAddress;
	address superAdmin;
	address admin;
	address etherVault;
	address etherGasProvider;
	mapping(address => Contact) public allContacts;
	address[] public contactsAddresses;
	
	bool tokenContractAddressReady;
	bool LEXtokenContractAddressReady;
	
	ERC223 public tokenReward;
	ERC223 public LEXToken;
	
	OperationInQueue[] public operationsInQueue;
	uint public currentOperation;
	
	modifier onlyAdmin()
	{
	    require(msg.sender == admin || msg.sender == superAdmin);
	    _;
	}
	
	modifier onlySuperAdmin()
	{
	    require(msg.sender == superAdmin);
	    _;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	function AumICO() public {
	    superAdmin = msg.sender;
	    admin = msg.sender;
		etherPrice = 100055; 
		etherInContract = 0;
		LEXInContract = 0;
		usdEstimateInContract = 19687500000000000; 
		tokenPrice[0] = 35;
		tokenPrice[1] = 55;
		tokenPrice[2] = 75;
		availableTokens[0] = 0;
		availableTokens[1] = preICOAvailableTokens * 10**8;
		availableTokens[2] = ICOAvailableTokens * 10**8;
		tokenCurrentStage = 0;
		tokenContractAddressReady = false;
		LEXtokenContractAddressReady = false;
		etherVault = 0x1FE5e535C3BB002EE0ba499a41f66677fC383424;
		etherGasProvider = 0x1FE5e535C3BB002EE0ba499a41f66677fC383424;
		tokenVaultAddress = msg.sender;
		currentOperation = 0;
		hasICOFinished = false;
		lastPriceCheck = 0;
		currentSoftCapContact = 0;
	}
	
	function () payable {
		if(msg.sender == etherGasProvider)
		{
			return;
		}
		if(!allContacts[msg.sender].isOnWhitelist || (now < startEpochTimestamp && msg.sender != admin) || now >= endEpochTimestamp || hasICOFinished || !tokenContractAddressReady)
		{
			revert();
		}
        uint depositedEther = msg.value;
        uint currentVaultBalance = tokenReward.balanceOf(tokenVaultAddress);
        uint totalAddressDeposit = safeAdd(allContacts[msg.sender].depositedEther, depositedEther);
        uint leftoverEther = 0;
		if(depositedEther < minAmmountToInvest || totalAddressDeposit > maxAmmountToInvest)
		{
			bool canEtherPassthrough = false;
		    if(totalAddressDeposit > maxAmmountToInvest)
		    {
		        uint passthroughEther = safeSub(maxAmmountToInvest, allContacts[msg.sender].depositedEther);   
		        if(passthroughEther > 0)
		        {
		            depositedEther = safeSub(depositedEther, 100000);   
		            if(depositedEther > passthroughEther)
		            {
		                leftoverEther = safeSub(depositedEther, passthroughEther);   
		            }
		            depositedEther = passthroughEther;
		            canEtherPassthrough = true;
		        }
		    }
		    if(!canEtherPassthrough)
		    {
		        revert();    
		    }
		}
		if (currentVaultBalance > 0)
		{
		
			if(safeSub(now, lastPriceCheck) > 300)
			{
				operationsInQueue.push(OperationInQueue(now, depositedEther, msg.sender, false));
				updatePrice();
			}else
			{
				sendTokens(msg.sender, depositedEther);
			}
		}else 
		{
			revert();
		}
		if(leftoverEther > 0)
		{
		    msg.sender.transfer(leftoverEther);
		}
    }
    
	function sendTokens(address receiver, uint depositedEther) private 
	{
		if(tokenCurrentStage >= 3)
		{
			hasICOFinished = true;
			receiver.transfer(depositedEther);
		}else
		{
			uint obtainedTokensDividend = safeMul(etherPrice, depositedEther );
			uint obtainedTokensDivisor = safeMul(tokenPrice[tokenCurrentStage], 10**10 );
			uint obtainedTokens = safeDiv(obtainedTokensDividend, obtainedTokensDivisor);
			if(obtainedTokens > availableTokens[tokenCurrentStage])
			{
			    uint leftoverEther = depositedEther;
				if(availableTokens[tokenCurrentStage] > 0)
				{
				    uint tokensAvailableForTransfer = availableTokens[tokenCurrentStage];
				    uint leftoverTokens = safeSub(obtainedTokens, availableTokens[tokenCurrentStage]);
    				availableTokens[tokenCurrentStage] = 0;
    				uint leftoverEtherDividend = safeMul(leftoverTokens, tokenPrice[tokenCurrentStage] );
    				leftoverEtherDividend = safeMul(leftoverEtherDividend, 10**10 );
    				leftoverEther = safeDiv(leftoverEtherDividend, etherPrice);
    				
				    uint usedEther = safeSub(depositedEther, leftoverEther);
					etherInContract += usedEther;
					allContacts[receiver].obtainedTokens += tokensAvailableForTransfer;
			        allContacts[receiver].depositedEther += usedEther;
			        usdEstimateInContract += safeMul(tokensAvailableForTransfer, tokenPrice[tokenCurrentStage] );
					etherVault.transfer(depositedEther);
					tokenReward.transferFrom(tokenVaultAddress, receiver, tokensAvailableForTransfer);
				}
				tokenCurrentStage++;
				sendTokens(receiver, leftoverEther);
			}else
			{
			    usdEstimateInContract += safeMul(obtainedTokens, tokenPrice[tokenCurrentStage] );
				availableTokens[tokenCurrentStage] = safeSub(availableTokens[tokenCurrentStage], obtainedTokens);
				etherInContract += depositedEther;
				allContacts[receiver].obtainedTokens += obtainedTokens;
			    allContacts[receiver].depositedEther += depositedEther;
				etherVault.transfer(depositedEther);
				tokenReward.transferFrom(tokenVaultAddress, receiver, obtainedTokens);
			}
		}
	}
	
	
	function tokenFallback(address _from, uint _value, bytes _data) public
	{
		if(msg.sender != LEXTokenAddress || !LEXtokenContractAddressReady)
		{
			revert();
		}
		if(!allContacts[_from].isOnWhitelist || now < startEpochTimestamp || now >= endEpochTimestamp || hasICOFinished || !tokenContractAddressReady)
		{
			revert();
		}
		uint currentVaultBalance = tokenReward.balanceOf(tokenVaultAddress);
		if(currentVaultBalance > 0)
		{
			sendTokensForLEX(_from, _value);
		}else
		{
			revert();
		}
	}
	
	function sendTokensForLEX(address receiver, uint depositedLEX) private 
	{
		if(tokenCurrentStage >= 3)
		{
			hasICOFinished = true;
			LEXToken.transfer(receiver, depositedLEX);
		}else
		{
			uint depositedBalance = safeMul(depositedLEX, 100000000);
			uint obtainedTokens = safeDiv(depositedBalance, tokenPrice[tokenCurrentStage]);
			if(obtainedTokens > availableTokens[tokenCurrentStage])
			{
			    uint leftoverLEX = depositedLEX;
				if(availableTokens[tokenCurrentStage] > 0)
				{
				    uint tokensAvailableForTransfer = availableTokens[tokenCurrentStage];
				    uint leftoverTokens = safeSub(obtainedTokens, availableTokens[tokenCurrentStage]);
    				availableTokens[tokenCurrentStage] = 0;
    				uint leftoverLEXFactor = safeMul(leftoverTokens, tokenPrice[tokenCurrentStage] );
    				leftoverLEX = safeDiv(leftoverLEXFactor, 100000000);
    				
				    uint usedLEX = safeSub(depositedLEX, leftoverLEX);
					LEXInContract += usedLEX;
					allContacts[receiver].obtainedTokens += tokensAvailableForTransfer;
			        allContacts[receiver].depositedLEX += usedLEX;
			        usdEstimateInContract += safeMul(tokensAvailableForTransfer, tokenPrice[tokenCurrentStage] );
					tokenReward.transferFrom(tokenVaultAddress, receiver, tokensAvailableForTransfer);
				}
				tokenCurrentStage++;
				sendTokensForLEX(receiver, leftoverLEX);
			}else
			{
			    usdEstimateInContract += depositedLEX;
				availableTokens[tokenCurrentStage] = safeSub(availableTokens[tokenCurrentStage], obtainedTokens);
				LEXInContract += depositedLEX;
				allContacts[receiver].obtainedTokens += obtainedTokens;
			    allContacts[receiver].depositedLEX += depositedLEX;
				tokenReward.transferFrom(tokenVaultAddress, receiver, obtainedTokens);
			}
		}
	}
	
	
	
	function CheckQueue() private
	{
	    if(operationsInQueue.length > currentOperation)
	    {
    		if(!operationsInQueue[currentOperation].closed)
    		{
    		    operationsInQueue[currentOperation].closed = true;
    			if(safeSub(now, lastPriceCheck) > 300)
    			{
    				operationsInQueue.push(OperationInQueue(now, operationsInQueue[currentOperation].depositedEther, operationsInQueue[currentOperation].receiver, false));
    				updatePrice();
    				currentOperation++;
    				return;
    			}else
    			{
    				sendTokens(operationsInQueue[currentOperation].receiver, operationsInQueue[currentOperation].depositedEther);
    			}
    		}
    		currentOperation++;
	    }
	}
	
	function getTokenAddress() public constant returns (address) {
		return tokenContractAddress;
	}
	
	function getTokenBalance() public constant returns (uint) {
		return tokenReward.balanceOf(tokenVaultAddress);
	}
	
	
	function getEtherInContract() public constant returns (uint) {
		return etherInContract;
	}
	
	function ChangeAdmin(address newAdminAddress) public onlySuperAdmin {
		admin = newAdminAddress;
	}
	
	function GetQueueLength() public onlyAdmin constant returns (uint) {
		return safeSub(operationsInQueue.length, currentOperation);
	}
	
	function changeTokenAddress (address newTokenAddress) public onlyAdmin
	{
		tokenContractAddress = newTokenAddress;
		tokenReward = ERC223(tokenContractAddress);
		tokenContractAddressReady = true;
	}
	
	function ChangeLEXTokenAddress (address newLEXTokenAddress) public onlyAdmin
	{
		LEXTokenAddress = newLEXTokenAddress;
		LEXToken = ERC223(LEXTokenAddress);
		LEXtokenContractAddressReady = true;
	}
	
	function ChangeEtherVault(address newEtherVault) onlyAdmin public
	{
		etherVault = newEtherVault;
	}
	
	function ExtractEtherLeftOnContract(address newEtherGasProvider) onlyAdmin public
	{
		if(now > endEpochTimestamp)
	    {
			etherVault.transfer(this.balance);
		}
	}
	
	function ChangeEtherGasProvider(address newEtherGasProvider) onlyAdmin public
	{
		etherGasProvider = newEtherGasProvider;
	}
	
	function ChangeTokenVaultAddress(address newTokenVaultAddress) onlyAdmin public
	{
		tokenVaultAddress = newTokenVaultAddress;
	}
	
	function AdvanceQueue() onlyAdmin public
	{
		CheckQueue();
	}
	
	function UpdateEtherPriceNow() onlyAdmin public
	{
		updatePrice();
	}
	
	function CheckSoftCap() onlyAdmin public
	{
	    if(usdEstimateInContract < softCap && now > endEpochTimestamp && currentSoftCapContact < contactsAddresses.length)
	    {
	        for(uint i = currentSoftCapContact; i < 4;i++)
	        {
				if(i < contactsAddresses.length)
				{
					if(!allContacts[contactsAddresses[i]].userLiquidated)
					{
						allContacts[contactsAddresses[i]].userLiquidated = true;
						allContacts[contactsAddresses[i]].depositedEther = 0;
						contactsAddresses[i].transfer(allContacts[contactsAddresses[i]].depositedEther);
					}
					currentSoftCapContact++;
				}
	        }
	    }
	}
	
	function AddToWhitelist(address addressToAdd) onlyAdmin public
	{
	    if(!allContacts[addressToAdd].userExists)
		{
    		contactsAddresses.push(addressToAdd);
    		allContacts[addressToAdd].userExists = true;
		}
		allContacts[addressToAdd].isOnWhitelist = true;
	}
	
	function RemoveFromWhitelist(address addressToRemove) onlyAdmin public
	{
	    if(allContacts[addressToRemove].userExists)
		{
			allContacts[addressToRemove].isOnWhitelist = false;
		}
	}
	
	function GetAdminAddress() public returns (address)
	{
		return admin;
	}
	
	function IsOnWhitelist(address addressToCheck) public view returns(bool isOnWhitelist)
	{
		return allContacts[addressToCheck].isOnWhitelist;
	}
	
	function getPrice() public constant returns (uint) {
		return etherPrice;
	}
	
	function updatePrice() private
	{
		if (oraclize_getPrice("URL") > this.balance) {
            
        } else {
            
            oraclize_query("URL", "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD", 300000);
        }
	}
	
	function __callback(bytes32 _myid, string _result) {
		require (msg.sender == oraclize_cbAddress());
		etherPrice = parseInt(_result, 2);
		lastPriceCheck = now;
		CheckQueue();
	}
}