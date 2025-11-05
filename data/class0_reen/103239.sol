pragma solidity 0.4.20;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        assert(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        assert(b > 0);
        c = a / b;
        assert(a == b * c + a % b);
    }
}

contract Lockable is Pausable {
    mapping (address => uint) public locked;
    
    event Lockup(address indexed target, uint startTime, uint deadline);
    
    function lockup(address _target) onlyOwner public returns (bool success) {
	    require(!isManageable(_target));
        locked[_target] = SafeMath.add(now, SafeMath.mul(LOCKUP_DURATION_TIME, TIME_FACTOR));
        Lockup(_target, now, locked[_target]);
        return true;
    }
    
    
    function isLockup(address _target) internal constant returns (bool) {
        if(now <= locked[_target])
            return true;
    }
}

interface tokenRecipient { 
    function receiveApproval(address _from, uint _value, address _token, bytes _extraData) external; 
}
