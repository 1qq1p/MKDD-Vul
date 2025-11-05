pragma solidity ^0.4.15;







library DateTime {
        



        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint private constant DAY_IN_SECONDS = 86400;
        uint private constant YEAR_IN_SECONDS = 31536000;
        uint private constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint private constant HOUR_IN_SECONDS = 3600;
        uint private constant MINUTE_IN_SECONDS = 60;

        uint16 private constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) public constant returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public constant  returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public constant  returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal constant returns (_DateTime dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                
                dt.hour = getHour(timestamp);

                
                dt.minute = getMinute(timestamp);

                
                dt.second = getSecond(timestamp);

                
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public constant returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public constant returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public constant returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public constant returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public constant returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public constant returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public constant returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public constant returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public constant returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public constant returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public constant returns (uint timestamp) {
                uint16 i;

                
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                
                timestamp += DAY_IN_SECONDS * (day - 1);

                
                timestamp += HOUR_IN_SECONDS * (hour);

                
                timestamp += MINUTE_IN_SECONDS * (minute);

                
                timestamp += second;

                return timestamp;
        }

		
		
		
		function compareDatesWithoutTime(uint t1, uint t2) public constant returns (int res)
		{
			_DateTime memory dt1 = parseTimestamp(t1);
			_DateTime memory dt2 = parseTimestamp(t2);

			res = compareInts(dt1.year, dt2.year);
			if (res == 0)
			{
				res = compareInts(dt1.month, dt2.month);
				if (res == 0)
				{
					res = compareInts(dt1.day, dt2.day);
				}
			}
		}


		
		
		
		
		
		
		function compareDateTimesForContract(uint t1, uint t2) public constant returns (int res)
		{
		    uint endOfDay = t2 + (60 * 60 * 24);
		    res = 0;
		    
		    if (t2 <= t1 && t1 <= endOfDay)
		    {
		        res = 0;
		    }
		    else if (t2 > t1)
		    {
		        res = -1;
		    }
		    else if (t1 > endOfDay)
		    {
		        res = 1;
		    }
		}	


		
		
		
		function compareInts(int n1, int n2) internal constant returns (int res)
		{
			if (n1 == n2)
			{
				res = 0;
			}
			else if (n1 < n2)
			{
				res = -1;
			}
			else if (n1 > n2)
			{
				res = 1;
			}
		}
}





contract StayBitContractFactory is Ownable
{
    struct EscrowTokenInfo { 
		uint _RentMin;  
		uint _RentMax;  
		address _ContractAddress; 
		uint _ContractFeeBal;  
    }

	using BaseEscrowLib for BaseEscrowLib.EscrowContractState;
    mapping(bytes32 => BaseEscrowLib.EscrowContractState) private contracts;
	mapping(uint => EscrowTokenInfo) private supportedTokens;
	bool private CreateEnabled; 
	bool private PercentageFee;  
	uint ContractFee;  
		
	event contractCreated(int rentPerDay, int cancelPolicy, uint moveInDate, uint moveOutDate, int secDeposit, address landlord, uint tokenId, int Id, string Guid, uint extraAmount);
	event contractTerminated(int Id, string Guid, int State);

	function StayBitContractFactory()
	{
		CreateEnabled = true;
		PercentageFee = false;
		ContractFee = 0;
	}

	function SetFactoryParams(bool enable, bool percFee, uint contrFee) public onlyOwner
	{
		CreateEnabled = enable;	
		PercentageFee = percFee;
		ContractFee = contrFee;
	}

	function GetFeeBalance(uint tokenId) public constant returns (uint)
	{
		return supportedTokens[tokenId]._ContractFeeBal;
	}

	function WithdrawFeeBalance(uint tokenId, address to, uint amount) public onlyOwner
	{	    
		require(supportedTokens[tokenId]._RentMax > 0);		
		require(supportedTokens[tokenId]._ContractFeeBal >= amount);		
		supportedTokens[tokenId]._ContractFeeBal -= amount;		
		ERC20Interface tokenApi = ERC20Interface(supportedTokens[tokenId]._ContractAddress);
		tokenApi.transfer(to, amount);
	}


	function SetTokenInfo(uint tokenId, address tokenAddress, uint rentMin, uint rentMax) public onlyOwner
	{
		supportedTokens[tokenId]._RentMin = rentMin;
		supportedTokens[tokenId]._RentMax = rentMax;
		supportedTokens[tokenId]._ContractAddress = tokenAddress;
	}

	function CalculateCreateFee(uint amount) public constant returns (uint)
	{
		uint result = 0;
		if (PercentageFee)
		{
			result = amount * ContractFee / 100;
		}
		else
		{
			result = ContractFee;
		}
		return result;
	}


    
	function CreateContract(int rentPerDay, int cancelPolicy, uint moveInDate, uint moveOutDate, int secDeposit, address landlord, string doorLockData, uint tokenId, int Id, string Guid, uint extraAmount) public
	{
		
		require (CreateEnabled && rentPerDay > 0 && secDeposit > 0 && moveInDate > 0 && moveOutDate > 0 && landlord != address(0) && landlord != msg.sender && Id > 0);

		
		require(supportedTokens[tokenId]._RentMax > 0);

		
		require(supportedTokens[tokenId]._RentMin <= uint(rentPerDay) && supportedTokens[tokenId]._RentMax >= uint(rentPerDay));

		
		
		

		
		require (cancelPolicy == 1 || cancelPolicy == 2);

		
		require (contracts[keccak256(Guid)]._Id == 0);

		contracts[keccak256(Guid)]._CurrentDate = now;
		contracts[keccak256(Guid)]._CreatedDate = now;
		contracts[keccak256(Guid)]._RentPerDay = rentPerDay;
		contracts[keccak256(Guid)]._MoveInDate = moveInDate;
		contracts[keccak256(Guid)]._MoveOutDate = moveOutDate;
		contracts[keccak256(Guid)]._SecDeposit = secDeposit;
		contracts[keccak256(Guid)]._DoorLockData = doorLockData;
		contracts[keccak256(Guid)]._landlord = landlord;
		contracts[keccak256(Guid)]._tenant = msg.sender;
		contracts[keccak256(Guid)]._ContractAddress = this;		
		contracts[keccak256(Guid)]._tokenApi = ERC20Interface(supportedTokens[tokenId]._ContractAddress);
		contracts[keccak256(Guid)]._Id = Id;
		contracts[keccak256(Guid)]._Guid = Guid;
		contracts[keccak256(Guid)]._CancelPolicy = cancelPolicy;

		contracts[keccak256(Guid)].initialize();

		uint256 startBalance = contracts[keccak256(Guid)]._tokenApi.balanceOf(this);

		
		supportedTokens[tokenId]._ContractFeeBal += CalculateCreateFee(uint(contracts[keccak256(Guid)]._TotalAmount));

		
		require(extraAmount + uint(contracts[keccak256(Guid)]._TotalAmount) + CalculateCreateFee(uint(contracts[keccak256(Guid)]._TotalAmount)) <= contracts[keccak256(Guid)]._tokenApi.balanceOf(msg.sender));

		
		contracts[keccak256(Guid)]._tokenApi.transferFrom(msg.sender, this, extraAmount + uint(contracts[keccak256(Guid)]._TotalAmount) + CalculateCreateFee(uint(contracts[keccak256(Guid)]._TotalAmount)));

		
		contracts[keccak256(Guid)]._Balance = contracts[keccak256(Guid)]._tokenApi.balanceOf(this) - startBalance - CalculateCreateFee(uint(contracts[keccak256(Guid)]._TotalAmount));

		
		require(contracts[keccak256(Guid)]._Balance >= uint(contracts[keccak256(Guid)]._TotalAmount));

		
		contractCreated(rentPerDay, cancelPolicy, moveInDate, moveOutDate, secDeposit, landlord, tokenId, Id, Guid, extraAmount);
	}

	function() payable
	{	
		revert();
	}

	function SimulateCurrentDate(uint n, string Guid) public {
	    if (contracts[keccak256(Guid)]._Id != 0)
		{
			contracts[keccak256(Guid)].SimulateCurrentDate(n);
		}
	}
	
	
	function GetContractInfo(string Guid) public constant returns (uint curDate, int escrState, int escrStage, bool tenantMovedIn, uint actualBalance, bool misrepSignaled, string doorLockData, int calcAmount, uint actualMoveOutDate, int cancelPolicy)
	{
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			actualBalance = contracts[keccak256(Guid)].GetContractBalance();
			curDate = contracts[keccak256(Guid)].GetCurrentDate();
			tenantMovedIn = contracts[keccak256(Guid)]._TenantConfirmedMoveIn;
			misrepSignaled = contracts[keccak256(Guid)]._MisrepSignaled;
			doorLockData = contracts[keccak256(Guid)]._DoorLockData;
			escrStage = contracts[keccak256(Guid)].GetCurrentStage();
			escrState = contracts[keccak256(Guid)]._State;
			calcAmount = contracts[keccak256(Guid)]._TotalAmount;
			actualMoveOutDate = contracts[keccak256(Guid)]._ActualMoveOutDate;
			cancelPolicy = contracts[keccak256(Guid)]._CancelPolicy;
		}
	}
		
	function TenantTerminate(string Guid) public
	{
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			require(contracts[keccak256(Guid)]._State == BaseEscrowLib.GetContractStateActive() && msg.sender == contracts[keccak256(Guid)]._tenant);

			if (contracts[keccak256(Guid)]._CancelPolicy == 1)
			{
				FlexibleEscrowLib.TenantTerminate(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 2)
			{
				ModerateEscrowLib.TenantTerminate(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 3)
			{
				StrictEscrowLib.TenantTerminate(contracts[keccak256(Guid)]);
			}
			else{
				revert();
				return;
			}

			SendTokens(Guid);

			
			contractTerminated(contracts[keccak256(Guid)]._Id, Guid, contracts[keccak256(Guid)]._State);

		}
	}

	function TenantTerminateMisrep(string Guid) public
	{	
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			require(contracts[keccak256(Guid)]._State == BaseEscrowLib.GetContractStateActive() && msg.sender == contracts[keccak256(Guid)]._tenant);

			if (contracts[keccak256(Guid)]._CancelPolicy == 1)
			{
				FlexibleEscrowLib.TenantTerminateMisrep(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 2)
			{
				ModerateEscrowLib.TenantTerminateMisrep(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 3)
			{
				StrictEscrowLib.TenantTerminateMisrep(contracts[keccak256(Guid)]);
			}
			else{
				revert();
				return;
			}

			SendTokens(Guid);

			
			contractTerminated(contracts[keccak256(Guid)]._Id, Guid, contracts[keccak256(Guid)]._State);
		}
	}
    
	function TenantMoveIn(string Guid) public
	{	
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			require(contracts[keccak256(Guid)]._State == BaseEscrowLib.GetContractStateActive() && msg.sender == contracts[keccak256(Guid)]._tenant);

			if (contracts[keccak256(Guid)]._CancelPolicy == 1)
			{
				FlexibleEscrowLib.TenantMoveIn(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 2)
			{
				ModerateEscrowLib.TenantMoveIn(contracts[keccak256(Guid)]);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 3)
			{
				StrictEscrowLib.TenantMoveIn(contracts[keccak256(Guid)]);
			}
			else{
				revert();
			}
		}
	}

	function LandlordTerminate(uint SecDeposit, string Guid) public
	{		
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			require(SecDeposit >= 0 && SecDeposit <= uint256(contracts[keccak256(Guid)]._SecDeposit));
			require(contracts[keccak256(Guid)]._State == BaseEscrowLib.GetContractStateActive() && msg.sender == contracts[keccak256(Guid)]._landlord);

			if (contracts[keccak256(Guid)]._CancelPolicy == 1)
			{
				FlexibleEscrowLib.LandlordTerminate(contracts[keccak256(Guid)], SecDeposit);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 2)
			{
				ModerateEscrowLib.LandlordTerminate(contracts[keccak256(Guid)], SecDeposit);
			}
			else if (contracts[keccak256(Guid)]._CancelPolicy == 3)
			{
				StrictEscrowLib.LandlordTerminate(contracts[keccak256(Guid)], SecDeposit);
			}
			else{
				revert();
				return;
			}

			SendTokens(Guid);

			
			contractTerminated(contracts[keccak256(Guid)]._Id, Guid, contracts[keccak256(Guid)]._State);
		}
	}

	function SendTokens(string Guid) private
	{		
		if (contracts[keccak256(Guid)]._Id != 0)
		{
			if (contracts[keccak256(Guid)]._landlBal > 0)
			{	
				uint landlBal = uint(contracts[keccak256(Guid)]._landlBal);
				contracts[keccak256(Guid)]._landlBal = 0;		
				contracts[keccak256(Guid)]._tokenApi.transfer(contracts[keccak256(Guid)]._landlord, landlBal);
				contracts[keccak256(Guid)]._Balance -= landlBal;						
			}
	    
			if (contracts[keccak256(Guid)]._tenantBal > 0)
			{			
				uint tenantBal = uint(contracts[keccak256(Guid)]._tenantBal);
				contracts[keccak256(Guid)]._tenantBal = 0;
				contracts[keccak256(Guid)]._tokenApi.transfer(contracts[keccak256(Guid)]._tenant, tenantBal);			
				contracts[keccak256(Guid)]._Balance -= tenantBal;
			}
		}			    
	}
}