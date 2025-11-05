
pragma solidity ^0.4.24;

library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns(uint c) {
        if (a > b) return b;
        return a;
    }
}

library SafeMath {

    


    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        
        
        
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    


    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); 
        uint256 c = _a / _b;
        

        return c;
    }

    


    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    


    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract CaelumAcceptERC20 is Ownable, CaelumVotings, abstractCaelum { 
    using SafeMath for uint;

    address[] public tokensList;
    bool setOwnContract = true;

    struct _whitelistTokens {
        address tokenAddress;
        bool active;
        uint requiredAmount;
        uint validUntil;
        uint timestamp;
    }

    mapping(address => mapping(address => uint)) public tokens;
    mapping(address => _whitelistTokens) acceptedTokens;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    



    function getMiningReward() public view returns(uint) {
        return 50 * 1e8;
    }


    




    function addOwnToken() onlyOwner public returns (bool) {
        require(setOwnContract);
        addToWhitelist(this, 5000 * 1e8, 36500);
        setOwnContract = false;
        return true;
    }

    
    





    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal {
        _whitelistTokens storage newToken = acceptedTokens[_token];
        newToken.tokenAddress = _token;
        newToken.requiredAmount = _amount;
        newToken.timestamp = now;
        newToken.validUntil = now + (daysAllowed * 1 days);
        newToken.active = true;

        tokensList.push(_token);
    }

    




    function isAcceptedToken(address _ad) internal view returns(bool) {
        return acceptedTokens[_ad].active;
    }

    




    function getAcceptedTokenAmount(address _ad) internal view returns(uint) {
        return acceptedTokens[_ad].requiredAmount;
    }

    




    function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true;
        return false;
    }

    



    function listAcceptedTokens() public view returns(address[]) {
        return tokensList;
    }

    



    function getTokenDetails(address token) public view returns(address ad,uint required, bool active, uint valid) {
        return (acceptedTokens[token].tokenAddress, acceptedTokens[token].requiredAmount,acceptedTokens[token].active, acceptedTokens[token].validUntil);
    }

    




    function depositCollateral(address token, uint amount) public {
        require(isAcceptedToken(token), "ERC20 not authorised");  
        require(amount == getAcceptedTokenAmount(token));         
        require(isValid(token));                                  

        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);

        require(StandardToken(token).transferFrom(msg.sender, this, amount), "error with token");
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        addMasternode(msg.sender);
    }

    




    function withdrawCollateral(address token, uint amount) public {
        require(token != 0); 
        require(isAcceptedToken(token), "ERC20 not authorised"); 
        require(isMasternodeOwner(msg.sender)); 
        require(tokens[token][msg.sender] == amount); 

        uint amountToWithdraw = tokens[token][msg.sender];
        tokens[token][msg.sender] = 0;

        deleteMasternode(getLastPerUser(msg.sender));

        if (!StandardToken(token).transfer(msg.sender, amountToWithdraw)) revert();
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);
    }

}
