pragma solidity ^0.5.4;

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

contract TimeLockToken is StandardToken, Ownable {
    mapping (address => uint) public timelockAccounts;
    event TimeLockFunds(address target, uint releasetime);

    function timelockAccount(address target, uint releasetime) public onlyOwner {
        uint r_time;
        r_time = now + (releasetime * 1 days);
        timelockAccounts[target] = r_time;
        emit TimeLockFunds(target, r_time);
    }

    function timeunlockAccount(address target) public onlyOwner {
        timelockAccounts[target] = now;
        emit TimeLockFunds(target, now);
    }

    function releasetime(address _target) view public returns (uint){
        return timelockAccounts[_target];
    }

    modifier ReleaseTimeTransfer(address _sender) {
        require(now >= timelockAccounts[_sender]);
        _;
    }

    function transfer(address _to, uint256 _value) public ReleaseTimeTransfer(msg.sender) returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public ReleaseTimeTransfer(_from) returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }
}
