pragma solidity ^0.4.21;







library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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


contract TMSYToken is CommonToken {
    constructor(
      address _seller,
      address _teamWallet,
      address _partnersWallet,
      address _advisorsWallet,
      address _reservaWallet) CommonToken(
        _seller,
        _teamWallet,
        _partnersWallet,
        _advisorsWallet,
        _reservaWallet
    ) public {}
}