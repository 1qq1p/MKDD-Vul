pragma solidity >=0.4.22 <0.6.0;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
}
