pragma solidity ^0.4.23;







contract TRVLToken is RewardToken {
    string public constant name = "TRVL Token";
    string public constant symbol = "TRVL";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_CAP = 600000000 * (10 ** uint256(decimals));

    event TransferReward(address from, address to, uint256 value);

    
    modifier senderHasEnoughTokens(uint256 _regularTokens, uint256 _rewardTokens) {
        require(rewardBalances[msg.sender] >= _rewardTokens, "User does not have enough reward tokens!");
        require(balances[msg.sender] >= _regularTokens, "User does not have enough regular tokens!");
        _;
    }

    
    modifier validAmount(uint256 _amount) {
        require(_amount > 0, "The amount specified is 0!");
        _;
    }

    
    
    
    
    
    constructor() RewardToken(decimals) public {
        totalSupply_ = TOTAL_CAP;
        balances[owner] = totalSupply_;
        emit Transfer(0x0, owner, totalSupply_);
    }

    
    
    
    
    function paymentRegularTokensPriority (uint256 _amount, uint256 _rewardPercentageIndex) public {
        uint256 regularTokensAvailable = balances[msg.sender];

        if (regularTokensAvailable >= _amount) {
            paymentRegularTokens(_amount, _rewardPercentageIndex);

        } else {
            if (regularTokensAvailable > 0) {
                uint256 amountOfRewardsTokens = _amount.sub(regularTokensAvailable);
                paymentMixed(regularTokensAvailable, amountOfRewardsTokens, _rewardPercentageIndex);
            } else {
                paymentRewardTokens(_amount);
            }
        }
    }

    
    
    
    
    function paymentRewardTokensPriority (uint256 _amount, uint256 _rewardPercentageIndex) public {
        uint256 rewardTokensAvailable = rewardBalances[msg.sender];

        if (rewardTokensAvailable >= _amount) {
            paymentRewardTokens(_amount);
        } else {
            if (rewardTokensAvailable > 0) {
                uint256 amountOfRegularTokens = _amount.sub(rewardTokensAvailable);
                paymentMixed(amountOfRegularTokens, rewardTokensAvailable, _rewardPercentageIndex);
            } else {
                paymentRegularTokens(_amount, _rewardPercentageIndex);
            }
        }
    }

    
    
    
    
    function paymentMixed (uint256 _regularTokenAmount, uint256 _rewardTokenAmount, uint256 _rewardPercentageIndex) public {
        paymentRewardTokens(_rewardTokenAmount);
        paymentRegularTokens(_regularTokenAmount, _rewardPercentageIndex);
    }

    
    
    
    
    
    
    
    
    
    
    
    function paymentRegularTokens (uint256 _regularTokenAmount, uint256 _rewardPercentageIndex)
        public
        validAmount(_regularTokenAmount)
        isValidRewardIndex(_rewardPercentageIndex)
        senderHasEnoughTokens(_regularTokenAmount, 0)
        isWhitelisted(msg.sender)
        whenNotPaused
    {
        
        balances[msg.sender] = balances[msg.sender].sub(_regularTokenAmount);

        
        uint256 rewardAmount = getRewardToken(_regularTokenAmount, _rewardPercentageIndex);
        rewardBalances[msg.sender] = rewardBalances[msg.sender].add(rewardAmount);
        emit TransferReward(owner, msg.sender, rewardAmount);

        
        balances[owner] = balances[owner].add(_regularTokenAmount.sub(rewardAmount));
        emit Transfer(msg.sender, owner, _regularTokenAmount.sub(rewardAmount));
    }

    
    
    
    
    
    
    
    
    
    function paymentRewardTokens (uint256 _rewardTokenAmount)
        public
        validAmount(_rewardTokenAmount)
        senderHasEnoughTokens(0, _rewardTokenAmount)
        isWhitelisted(msg.sender)
        whenNotPaused
    {
        rewardBalances[msg.sender] = rewardBalances[msg.sender].sub(_rewardTokenAmount);
        rewardBalances[owner] = rewardBalances[owner].add(_rewardTokenAmount);

        emit TransferReward(msg.sender, owner, _rewardTokenAmount);
    }

    
    
    
    
    
    
    
    
    function convertRegularToRewardTokens(address _user, uint256 _amount)
        external
        onlyOwner
        validAmount(_amount)
        senderHasEnoughTokens(_amount, 0)
        isWhitelisted(_user)
    {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        rewardBalances[_user] = rewardBalances[_user].add(_amount);

        emit TransferReward(msg.sender, _user, _amount);
    }
}