pragma solidity 0.4.18;









library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Pausable is Ownable {
    event Paused();
    event Unpaused();

    bool public pause = false;

    modifier whenNotPaused() {
        require(!pause);
        _;
    }

    modifier whenPaused() {
        require(pause);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        pause = true;
        Paused();
    }

    function unpause() onlyOwner whenPaused public {
        pause = false;
        Unpaused();
    }
}
