pragma solidity ^0.4.24;





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






contract CoinMetroVault is Ownable {
    using SafeMath for uint256;

    CoinMetroToken public token;

    address public masterWallet;
    uint256 public releaseTimestamp;

    event TokenReleased(address _masterWallet, uint256 _amount);

    constructor(CoinMetroToken _token, address _masterWallet, uint256 _releaseTimestamp) public {
        require(_masterWallet != address(0x0));
        require(_releaseTimestamp > now);
        token = _token;
        masterWallet = _masterWallet;
        releaseTimestamp = _releaseTimestamp;
    }

    function() external payable {
        
        revert();
    }

    
    
    function release() external {
        require(now > releaseTimestamp, "Transaction locked");
        uint balance = token.balanceOf(address(this));
        token.transfer(masterWallet, balance);

        emit TokenReleased(masterWallet, balance);
    }
}