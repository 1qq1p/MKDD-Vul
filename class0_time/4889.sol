pragma solidity ^0.4.8;







































contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        require(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y));
        return z;
    }

}





