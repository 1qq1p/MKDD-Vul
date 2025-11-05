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
    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b>=a) return 0;
        return a - b;
    }
}

contract MintableToken is StandardToken, GuidedByRoles {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    





    function mint(address _to, uint256 _amount) public returns (bool) {
        require(rightAndRoles.onlyRoles(msg.sender,1));
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
}
