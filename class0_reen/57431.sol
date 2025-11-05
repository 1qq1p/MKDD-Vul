pragma solidity ^0.4.21;






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







contract Grantable is BasicToken {
    using SafeMath for uint256;

    mapping(address => uint256) grants;

    event PreGrant(address indexed from, address indexed to, uint256 value);
    event Grant(address indexed from, address indexed to, uint256 value);

    function preGrant(address _to, uint256 _value) onlyOwner whenNotPaused public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        
        grants[_to] = grants[_to].add(_value);
        emit PreGrant(msg.sender, _to, _value);
        return true;
    }

    function grant(address _to, uint256 _value) onlyOwner whenNotPaused public returns (bool success) {
        require(_to != address(0));
        require(_value <= grants[_to]);
        require(_value > 0);

        grants[_to] = grants[_to].sub(_value);
        
        balances[_to] = balances[_to].add(_value);
        emit Grant(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function grantOf(address _owner) public view returns (uint256) {
        return grants[_owner];
    }
}

