pragma solidity 0.5.9;









library SafeMath {

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




contract ApproveAndCallFallBack {
 
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
 
}




