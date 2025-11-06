pragma solidity ^0.5.8;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}





interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}













contract DarknodePaymentStore is Claimable {
    using SafeMath for uint256;
    using CompatibleERC20Functions for ERC20;

    string public VERSION; 

    
    address constant public ETHEREUM = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    
    uint256 public darknodeWhitelistLength;

    
    mapping(address => mapping(address => uint256)) public darknodeBalances;

    
    mapping(address => uint256) public lockedBalances;

    
    mapping(address => uint256) public darknodeBlacklist;

    
    mapping(address => uint256) public darknodeWhitelist;

    
    
    
    constructor(
        string memory _VERSION
    ) public {
        VERSION = _VERSION;
    }

    
    function () external payable {
    }

    
    
    
    
    function isBlacklisted(address _darknode) public view returns (bool) {
        return darknodeBlacklist[_darknode] != 0;
    }

    
    
    
    
    function isWhitelisted(address _darknode) public view returns (bool) {
        return darknodeWhitelist[_darknode] != 0;
    }

    
    
    
    
    function totalBalance(address _token) public view returns (uint256) {
        if (_token == ETHEREUM) {
            return address(this).balance;
        } else {
            return ERC20(_token).balanceOf(address(this));
        }
    }

    
    
    
    
    
    
    function availableBalance(address _token) public view returns (uint256) {
        return totalBalance(_token).sub(lockedBalances[_token]);
    }

    
    
    
    
    
    function blacklist(address _darknode) external onlyOwner {
        require(!isBlacklisted(_darknode), "darknode already blacklisted");
        darknodeBlacklist[_darknode] = now;

        
        if (isWhitelisted(_darknode)) {
            darknodeWhitelist[_darknode] = 0;
            
            darknodeWhitelistLength = darknodeWhitelistLength.sub(1);
        }
    }

    
    
    
    
    function whitelist(address _darknode) external onlyOwner {
        require(!isBlacklisted(_darknode), "darknode is blacklisted");
        require(!isWhitelisted(_darknode), "darknode already whitelisted");

        darknodeWhitelist[_darknode] = now;
        darknodeWhitelistLength++;
    }

    
    
    
    
    
    
    function incrementDarknodeBalance(address _darknode, address _token, uint256 _amount) external onlyOwner {
        require(_amount > 0, "invalid amount");
        require(availableBalance(_token) >= _amount, "insufficient contract balance");

        darknodeBalances[_darknode][_token] = darknodeBalances[_darknode][_token].add(_amount);
        lockedBalances[_token] = lockedBalances[_token].add(_amount);
    }

    
    
    
    
    
    
    function transfer(address _darknode, address _token, uint256 _amount, address payable _recipient) external onlyOwner {
        require(darknodeBalances[_darknode][_token] >= _amount, "insufficient darknode balance");
        darknodeBalances[_darknode][_token] = darknodeBalances[_darknode][_token].sub(_amount);
        lockedBalances[_token] = lockedBalances[_token].sub(_amount);

        if (_token == ETHEREUM) {
            _recipient.transfer(_amount);
        } else {
            ERC20(_token).safeTransfer(_recipient, _amount);
        }
    }

}