







pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
library Math {
    function min(uint a, uint b) internal pure returns(uint) {
        if (a > b) {
            return b;
        }
        return a;
    }
}


library Zero {
    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function requireNotZero(uint val) internal pure {
        require(val != 0, "require not zero value");
    }

    function notZero(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns(bool) {
        return addr == address(0);
    }

    function isZero(uint a) internal pure returns(bool) {
        return a == 0;
    }

    function notZero(uint a) internal pure returns(bool) {
        return a != 0;
    }
}


library Percent {
    struct percent {
        uint num;
        uint den;
    }

    function mul(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a*p.num/p.den;
    }

    function div(percent storage p, uint a) internal view returns (uint) {
        return a/p.num*p.den;
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
        uint b = mul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function add(percent storage p, uint a) internal view returns (uint) {
        return a + mul(p, a);
    }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
        return Percent.percent(p.num, p.den);
    }

    function mmul(percent memory p, uint a) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a*p.num/p.den;
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
        return a/p.num*p.den;
    }

    function msub(percent memory p, uint a) internal pure returns (uint) {
        uint b = mmul(p, a);
        if (b >= a) {
            return 0;
        }
        return a - b;
    }

    function madd(percent memory p, uint a) internal pure returns (uint) {
        return a + mmul(p, a);
    }
}


library Address {
    function toAddress(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
        uint length;
        assembly { length := extcodesize(addr) }
        return length == 0;
    }
}


library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); 
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract InvestorsStorage is Accessibility {
    struct Investment {
        uint value;
        uint date;
        bool partiallyWithdrawn;
        bool fullyWithdrawn;
    }

    struct Investor {
        uint overallInvestment;
        uint paymentTime;
        Investment[] investments;
        Percent.percent individualPercent;
    }
    uint public size;

    mapping (address => Investor) private investors;

    function isInvestor(address addr) public view returns (bool) {
        return investors[addr].overallInvestment > 0;
    }

    function investorInfo(address addr)  returns(uint overallInvestment, uint paymentTime, Investment[] investments, Percent.percent individualPercent) {
        overallInvestment = investors[addr].overallInvestment;
        paymentTime = investors[addr].paymentTime;
        investments = investors[addr].investments;
        individualPercent = investors[addr].individualPercent;
    }

    function updatePercent(address addr) private {
        uint investment = investors[addr].overallInvestment;
        if (investment < 1 ether) {
            investors[addr].individualPercent = Percent.percent(3,100);
        } else if (investment >= 1 ether && investment < 10 ether) {
            investors[addr].individualPercent = Percent.percent(4,100);
        } else if (investment >= 10 ether && investment < 50 ether) {
            investors[addr].individualPercent = Percent.percent(5,100);
        } else if (investment >= 150 ether && investment < 250 ether) {
            investors[addr].individualPercent = Percent.percent(7,100);
        } else if (investment >= 250 ether && investment < 500 ether) {
            investors[addr].individualPercent = Percent.percent(10,100);
        } else if (investment >= 500 ether && investment < 1000 ether) {
            investors[addr].individualPercent = Percent.percent(11,100);
        } else if (investment >= 1000 ether && investment < 2000 ether) {
            investors[addr].individualPercent = Percent.percent(14,100);
        } else if (investment >= 2000 ether && investment < 5000 ether) {
            investors[addr].individualPercent = Percent.percent(15,100);
        } else if (investment >= 5000 ether && investment < 10000 ether) {
            investors[addr].individualPercent = Percent.percent(18,100);
        } else if (investment >= 10000 ether && investment < 30000 ether) {
            investors[addr].individualPercent = Percent.percent(20,100);
        } else if (investment >= 30000 ether && investment < 60000 ether) {
            investors[addr].individualPercent = Percent.percent(27,100);
        } else if (investment >= 60000 ether && investment < 100000 ether) {
            investors[addr].individualPercent = Percent.percent(35,100);
        } else if (investment >= 100000 ether) {
            investors[addr].individualPercent = Percent.percent(100,100);
        }
    }

    function newInvestor(address addr, uint investmentValue, uint paymentTime) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment != 0 || investmentValue == 0) {
            return false;
        }
        investors[addr].overallInvestment = investmentValue;
        investors[addr].paymentTime = paymentTime;
        investors[addr].investments.push(Investment(investmentValue, paymentTime, false, false));
        size++;
        return true;
    }

    function addInvestment(address addr, uint value) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment == 0) {
            return false;
        }
        investors[addr].overallInvestment += value;
        investors[addr].investments.push(Investment(value, now, false, false));
        updatePercent(addr);
        return true;
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if (investors[addr].overallInvestment == 0) {
            return false;
        }
        investors[addr].paymentTime = paymentTime;
        return true;
    }

    function withdrawBody(address addr, uint limit) public onlyOwner returns (uint) {
        Investment[] investments = investors[addr].investments;
        uint valueToWithdraw = 0;
        for (uint i = 0; i < investments.length; i++) {
            if (!investments[i].partiallyWithdrawn && investments[i].date <= now - 30 days && valueToWithdraw + investments[i].value/2 <= limit) {
                investments[i].partiallyWithdrawn = true;
                valueToWithdraw += investments[i].value/2;
                investors[addr].overallInvestment -= investments[i].value/2;
            }

            if (!investments[i].fullyWithdrawn && investments[i].date <= now - 60 days && valueToWithdraw + investments[i].value/2 <= limit) {
                investments[i].fullyWithdrawn = true;
                valueToWithdraw += investments[i].value/2;
                investors[addr].overallInvestment -= investments[i].value/2;
            }
            return valueToWithdraw;
        }

        return valueToWithdraw;
    }

    function disqualify(address addr) public onlyOwner returns (bool) {
        investors[addr].overallInvestment = 0;
        investors[addr].investments.length = 0;
    }
}

