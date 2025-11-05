pragma solidity ^0.4.21;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract BDC is ERC223Token, Ownable {
    string public name = "BitDigitalCoin";
    string public symbol = "BDC";
    uint256 public decimals = 18;

    using SafeMath for uint;

    function BDC() public {
        owner = msg.sender;
        totalSupply_ = 1000000000 * (10 ** decimals);
        balances[owner] = totalSupply_;
        emit Transfer(address(0), owner, totalSupply_);
    }

    function() payable public {
        revert();
    }
}