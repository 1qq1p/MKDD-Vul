pragma solidity ^0.4.11;
contract ATMint is SafeMath, Owned {
    ATMToken public atmToken; 
    Contribution public contribution; 
    uint128 public fundingStartTime = 0;
    uint256 public lockStartTime = 0;
    
    uint256 public constant MIN_FUND = (0.01 ether);
    uint256 public constant CRAWDSALE_START_DAY = 1;
    uint256 public constant CRAWDSALE_EARLYBIRD_END_DAY = 3;
    uint256 public constant CRAWDSALE_END_DAY = 7;
    uint256 public constant THAW_CYCLE_USER = 6;
    uint256 public constant THAW_CYCLE_FUNDER = 6;
    uint256 public constant THAW_CYCLE_LENGTH = 30;
    uint256 public constant decimals = 8; 
    uint256 public constant MILLION = (10**6 * 10**decimals);
    uint256 public constant tokenTotal = 10000 * MILLION;  
    uint256 public constant tokenToFounder = 800 * MILLION;  
    uint256 public constant tokenToReserve = 5000 * MILLION;  
    uint256 public constant tokenToContributor = 4000 * MILLION; 
    uint256[] public tokenToReward = [0, (120 * MILLION), (50 * MILLION), (30 * MILLION), 0, 0, 0, 0]; 
    bool doOnce = false;
    
    mapping (address => bool) public collected;
    mapping (address => uint) public contributedToken;
    mapping (address => uint) public unClaimedToken;
    
    event LogRegister (address contributionAddr, address ATMTokenAddr);
    event LogCollect (address user, uint spendETHAmount, uint getATMAmount);
    event LogMigrate (address user, uint balance);
    event LogClaim (address user, uint claimNumberNow, uint unclaimedTotal, uint totalContributed);
    event LogClaimReward (address user, uint claimNumber);
    




    function initialize (address _contribution) onlyOwner {
        require( _contribution != address(0) );
        contribution = Contribution(_contribution);
        atmToken = new ATMToken(tokenTotal);
        
        setLockStartTime(now);
        
        lockToken(contribution.ethFundDeposit(), tokenToReserve);
        lockToken(contribution.investorDeposit(), tokenToFounder);
        
        claimUserToken(contribution.investorDeposit());
        claimFoundationToken();
        
        LogRegister(_contribution, atmToken);
    }
    




    function collect(address _user) {
        require(!collected[_user]);
        
        uint128 dailyContributedETH = 0;
        uint128 userContributedETH = 0;
        uint128 userTotalContributedETH = 0;
        uint128 reward = 0;
        uint128 rate = 0;
        uint128 totalATMToken = 0;
        uint128 rewardRate = 0;
        collected[_user] = true;
        for (uint day = CRAWDSALE_START_DAY; day <= CRAWDSALE_END_DAY; day++) {
            dailyContributedETH = cast( contribution.dailyTotals(day) );
            userContributedETH = cast( contribution.userBuys(day,_user) );
            if (dailyContributedETH > 0 && userContributedETH > 0) {
                
                rewardRate = wdiv(cast(tokenToReward[day]), dailyContributedETH);
                reward += wmul(userContributedETH, rewardRate);
                
                userTotalContributedETH += userContributedETH;
            }
        }
        rate = wdiv(cast(tokenToContributor), cast(contribution.totalContributedETH()));
        totalATMToken = wmul(rate, userTotalContributedETH);
        totalATMToken += reward;
        
        lockToken(_user, totalATMToken);
        
        claimUserToken(_user);
        LogCollect(_user, userTotalContributedETH, totalATMToken);
    }
    function lockToken(
        address _user,
        uint256 _amount
    ) internal {
        require(_user != address(0));
        contributedToken[_user] += _amount;
        unClaimedToken[_user] += _amount;
    }
    function setLockStartTime(uint256 _time) internal {
        lockStartTime = _time;
    }
    function cast(uint256 _x) constant internal returns (uint128 z) {
        require((z = uint128(_x)) == _x);
    }
    




    function claimReward(address _founder) onlyOwner {
        require(_founder != address(0));
        require(lockStartTime != 0);
        require(doOnce == false);
        uint256 rewards = 0;
        for (uint day = CRAWDSALE_START_DAY; day <= CRAWDSALE_EARLYBIRD_END_DAY; day++) {
            if(contribution.dailyTotals(day) == 0){
                rewards += tokenToReward[day];
            }
        }
        atmToken.transfer(_founder, rewards);
        doOnce = true;
        LogClaimReward(_founder, rewards);
    }
    
    function claimFoundationToken() {
        require(msg.sender == owner || msg.sender == contribution.ethFundDeposit());
        claimToken(contribution.ethFundDeposit(),THAW_CYCLE_FUNDER);
    }
    function claimUserToken(address _user) {
        claimToken(_user,THAW_CYCLE_USER);
    }
    function claimToken(address _user, uint256 _stages) internal {
        if (unClaimedToken[_user] == 0) {
            return;
        }
        uint256 currentStage = sub(now, lockStartTime) / (60*60 ) +1;
        if (currentStage == 0) {
            return;
        } else if (currentStage > _stages) {
            currentStage = _stages;
        }
        uint256 lockStages = _stages - currentStage;
        uint256 unClaimed = (contributedToken[_user] * lockStages) / _stages;
        if (unClaimedToken[_user] <= unClaimed) {
            return;
        }
        uint256 tmp = unClaimedToken[_user] - unClaimed;
        unClaimedToken[_user] = unClaimed;
        atmToken.transfer(_user, tmp);
        LogClaim(_user, tmp, unClaimed,contributedToken[_user]);
    }
    




    function disableATMExchange() onlyOwner {
        atmToken.setDisabled(true);
    }
    function enableATMExchange() onlyOwner {
        atmToken.setDisabled(false);
    }
    function migrateUserData() onlyOwner {
        for (var i=0; i< atmToken.getATMHoldersNumber(); i++){
            LogMigrate(atmToken.ATMHolders(i), atmToken.balances(atmToken.ATMHolders(i)));
        }
    }
    function kill() onlyOwner {
        atmToken.kill();
        selfdestruct(owner);
    }
}