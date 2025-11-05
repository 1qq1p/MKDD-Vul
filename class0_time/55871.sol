pragma solidity ^0.4.24;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        
        
        
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}







contract BulDex is Ownable {
    using SafeERC20 for ERC20;

    mapping(address => bool) users;

    ERC20 public promoToken;
    ERC20 public bullToken;

    uint public minVal = 365000000000000000000;
    uint public bullAmount = 3140000000000000000;

    constructor(address _promoToken, address _bullToken) public {
        promoToken = ERC20(_promoToken);
        bullToken = ERC20(_bullToken);
    }

    function exchange(address _user, uint _val) public {
        require(!users[_user]);
        require(_val >= minVal);
        users[_user] = true;
        bullToken.safeTransfer(_user, bullAmount);
    }




    
    
    
    
    function claimTokens(address _token) external onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
    }


    function setBullAmount(uint _amount) onlyOwner public {
        bullAmount = _amount;
    }
}