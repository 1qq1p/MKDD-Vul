pragma solidity ^0.5.0;


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


contract PrivateSale is TokenCapCrowdsale, TokenCapRefund {

    Vesting public vesting;
    mapping (address => uint256) public tokensVested;
    uint256 hodlStartTime;

    constructor (
        uint256 _startTime,
        uint256 _endTime,
        address payable _wallet,
        Whitelisting _whitelisting,
        Token _token,
        Vesting _vesting,
        uint256 _refundClosingTime,
        uint256 _refundClosingTokenCap,
        uint256 _tokenCap,
        uint256 _individualCap
    )
        public
        TokenCapCrowdsale(_tokenCap, _individualCap)
        TokenCapRefund(_refundClosingTime)
        BaseCrowdsale(_startTime, _endTime, _wallet, _token, _whitelisting)
    {
        _refundClosingTokenCap; 
        require( address(_vesting) != address(0), "Invalid address");
        vesting = _vesting;
    }

    function allocateTokens(uint256 index, uint256 tokens)
        external
        onlyOwner
        waitingTokenAllocation(index)
    {
        address contributor = contributions[index].contributor;
        require(now >= endTime);
        require(whitelisting.isInvestorApproved(contributor));

        require(checkAndUpdateSupply(totalSupply.add(tokens)));

        uint256 alreadyExistingTokens = token.balanceOf(contributor);
        require(withinIndividualCap(tokens.add(alreadyExistingTokens)));

        contributions[index].tokensAllocated = true;
        tokenRaised = tokenRaised.add(tokens);
        token.mint(contributor, tokens);
        token.sethodlPremium(contributor, tokens, hodlStartTime);

        emit TokenPurchase(
            msg.sender,
            contributor,
            contributions[index].weiAmount,
            tokens
        );
    }

    function vestTokens(address[] calldata beneficiary, uint256[] calldata tokens, uint8[] calldata userType) external onlyOwner {
        require(beneficiary.length == tokens.length && tokens.length == userType.length);
        uint256 length = beneficiary.length;
        for(uint i = 0; i<length; i++) {
            require(beneficiary[i] != address(0), "Invalid address");
            require(now >= endTime);
            require(checkAndUpdateSupply(totalSupply.add(tokens[i])));

            tokensVested[beneficiary[i]] = tokensVested[beneficiary[i]].add(tokens[i]);
            require(withinIndividualCap(tokensVested[beneficiary[i]]));

            tokenRaised = tokenRaised.add(tokens[i]);

            token.mint(address(vesting), tokens[i]);
            Vesting(vesting).initializeVesting(beneficiary[i], tokens[i], now, Vesting.VestingUser(userType[i]));
        }
    }

    function ownerAssignedTokens(address beneficiary, uint256 tokens)
        external
        onlyOwner
    {
        require(now >= endTime);
        require(whitelisting.isInvestorApproved(beneficiary));

        require(checkAndUpdateSupply(totalSupply.add(tokens)));

        uint256 alreadyExistingTokens = token.balanceOf(beneficiary);
        require(withinIndividualCap(tokens.add(alreadyExistingTokens)));
        tokenRaised = tokenRaised.add(tokens);

        token.mint(beneficiary, tokens);
        token.sethodlPremium(beneficiary, tokens, hodlStartTime);

        emit TokenPurchase(
            msg.sender,
            beneficiary,
            0,
            tokens
        );
    }

    function setHodlStartTime(uint256 _hodlStartTime) onlyOwner external{
        hodlStartTime = _hodlStartTime;
    }
}