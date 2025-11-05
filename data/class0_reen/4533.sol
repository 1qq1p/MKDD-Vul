pragma solidity 0.4.25;

contract InvestorsStorage {
    using SafeMath for uint;
    using Percent for Percent.percent;
    struct investor {
        uint keyIndex;
        uint value;
        uint paymentTime;
        uint refs;
        uint refBonus;
        uint pendingPayout;
        uint pendingPayoutTime;
    }
    struct recordStats {
        uint investors;
        uint invested;
    }
    struct itmap {
        mapping(uint => recordStats) stats;
        mapping(address => investor) data;
        address[] keys;
    }
    itmap private s;

    address private owner;
    
    Percent.percent private _percent = Percent.percent(1,100);

    event LogOwnerForInvestorContract(address addr);

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit LogOwnerForInvestorContract(msg.sender);
        s.keys.length++;
    }
    
    function getDividendsPercent(address addr) public view returns(uint num, uint den) {
        uint amount = s.data[addr].value.add(s.data[addr].refBonus);
        if(amount <= 10*10**18) { 
            return (15, 1000);
        } else if(amount <= 50*10**18) { 
            return (16, 1000);
        } else if(amount <= 100*10**18) { 
            return (17, 1000);
        } else if(amount <= 300*10**18) { 
            return (185, 10000); 
        } else {
            return (2, 100);
        }
    }

    function insert(address addr, uint value) public onlyOwner returns (bool) {
        uint keyIndex = s.data[addr].keyIndex;
        if (keyIndex != 0) return false;
        s.data[addr].value = value;
        keyIndex = s.keys.length++;
        s.data[addr].keyIndex = keyIndex;
        s.keys[keyIndex] = addr;
        return true;
    }

    function investorFullInfo(address addr) public view returns(uint, uint, uint, uint, uint, uint, uint) {
        return (
        s.data[addr].keyIndex,
        s.data[addr].value,
        s.data[addr].paymentTime,
        s.data[addr].refs,
        s.data[addr].refBonus,
        s.data[addr].pendingPayout,
        s.data[addr].pendingPayoutTime
        );
    }

    function investorBaseInfo(address addr) public view returns(uint, uint, uint, uint, uint, uint) {
        return (
        s.data[addr].value,
        s.data[addr].paymentTime,
        s.data[addr].refs,
        s.data[addr].refBonus,
        s.data[addr].pendingPayout,
        s.data[addr].pendingPayoutTime
        );
    }

    function investorShortInfo(address addr) public view returns(uint, uint) {
        return (
        s.data[addr].value,
        s.data[addr].refBonus
        );
    }

    function addRefBonus(address addr, uint refBonus, uint dividendsPeriod) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) {
            assert(insert(addr, 0));
        }

        uint time;
        if (s.data[addr].pendingPayoutTime == 0) {
            time = s.data[addr].paymentTime;
        } else {
            time = s.data[addr].pendingPayoutTime;
        }

        if(time != 0) {
            uint value = 0;
            uint256 daysAfter = now.sub(time).div(dividendsPeriod);
            if(daysAfter > 0) {
                value = _getValueForAddr(addr, daysAfter);
            }
            s.data[addr].refBonus += refBonus;
            uint256 hoursAfter = now.sub(time).mod(dividendsPeriod);
            if(hoursAfter > 0) {
                uint dailyDividends = _getValueForAddr(addr, 1);
                uint hourlyDividends = dailyDividends.div(dividendsPeriod).mul(hoursAfter);
                value = value.add(hourlyDividends);
            }
            if (s.data[addr].pendingPayoutTime == 0) {
                s.data[addr].pendingPayout = value;
            } else {
                s.data[addr].pendingPayout = s.data[addr].pendingPayout.add(value);
            }
        } else {
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
        }
        assert(setPendingPayoutTime(addr, now));
        return true;
    }

    function _getValueForAddr(address addr, uint daysAfter) internal returns (uint value) {
        (uint num, uint den) = getDividendsPercent(addr);
        _percent = Percent.percent(num, den);
        value = _percent.mul(s.data[addr].value.add(s.data[addr].refBonus)) * daysAfter;
    }

    function addRefBonusWithRefs(address addr, uint refBonus, uint dividendsPeriod) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) {
            assert(insert(addr, 0));
        }

        uint time;
        if (s.data[addr].pendingPayoutTime == 0) {
            time = s.data[addr].paymentTime;
        } else {
            time = s.data[addr].pendingPayoutTime;
        }

        if(time != 0) {
            uint value = 0;
            uint256 daysAfter = now.sub(time).div(dividendsPeriod);
            if(daysAfter > 0) {
                value = _getValueForAddr(addr, daysAfter);
            }
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
            uint256 hoursAfter = now.sub(time).mod(dividendsPeriod);
            if(hoursAfter > 0) {
                uint dailyDividends = _getValueForAddr(addr, 1);
                uint hourlyDividends = dailyDividends.div(dividendsPeriod).mul(hoursAfter);
                value = value.add(hourlyDividends);
            }
            if (s.data[addr].pendingPayoutTime == 0) {
                s.data[addr].pendingPayout = value;
            } else {
                s.data[addr].pendingPayout = s.data[addr].pendingPayout.add(value);
            }
        } else {
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
        }
        assert(setPendingPayoutTime(addr, now));
        return true;
    }

    function addValue(address addr, uint value) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].value += value;       
        return true;
    }

    function updateStats(uint dt, uint invested, uint investors) public {
        s.stats[dt].invested += invested;
        s.stats[dt].investors += investors;
    }
    
    function stats(uint dt) public view returns (uint invested, uint investors) {
        return ( 
        s.stats[dt].invested,
        s.stats[dt].investors
        );
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].paymentTime = paymentTime;
        return true;
    }

    function setPendingPayoutTime(address addr, uint payoutTime) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].pendingPayoutTime = payoutTime;
        return true;
    }

    function setPendingPayout(address addr, uint payout) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].pendingPayout = payout;
        return true;
    }
    
    function contains(address addr) public view returns (bool) {
        return s.data[addr].keyIndex > 0;
    }

    function size() public view returns (uint) {
        return s.keys.length;
    }

    function iterStart() public pure returns (uint) {
        return 1;
    }
}
