pragma solidity ^0.4.24;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a, "Safe ADD check");
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "Safe SUB check");
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "Safe MUL check");
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "Safe DIV check");
        c = a / b;
    }
}






