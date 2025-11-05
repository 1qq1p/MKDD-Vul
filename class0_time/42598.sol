pragma solidity ^0.4.15;
contract Base {
    modifier only(address allowed) {
        require(msg.sender == allowed);
        _;
    }
    
    
    
    uint constant internal L00 = 2 ** 0;
    uint constant internal L01 = 2 ** 1;
    uint constant internal L02 = 2 ** 2;
    uint constant internal L03 = 2 ** 3;
    uint constant internal L04 = 2 ** 4;
    uint constant internal L05 = 2 ** 5;
    uint private bitlocks = 0;
    modifier noAnyReentrancy {
        var _locks = bitlocks;
        require(_locks == 0);
        bitlocks = uint(-1);
        _;
        bitlocks = _locks;
    }
}




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