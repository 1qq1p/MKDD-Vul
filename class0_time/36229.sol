pragma solidity ^0.4.11;

contract SafeMath {
    

    function safeMul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        Assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns(uint) {
        Assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        Assert(c >= a && c >= b);
        return c;
    }

    function Assert(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}
