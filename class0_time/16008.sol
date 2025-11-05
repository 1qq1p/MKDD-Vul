






pragma solidity ^0.4.16;

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
contract NotaryPlatformToken{
    function isTokenContract() returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool);
}