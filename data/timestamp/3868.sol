pragma solidity ^0.4.18;








contract CircleCrowdsale is Ownable, MintedCrowdsale {

    
    
    enum CrowdsaleStage {
        AngelRound,
        PreSaleRound,
        OpenRound}

    
    
    uint256 public totalSupplyMax = 2000000000 * (10 ** 18); 

    uint256 public angelRound = 200000000 * (10 ** 18);   
    uint256 public preSaleRound = 400000000 * (10 ** 18);   
    uint256 public openRound = 200000000 * (10 ** 18);   

    uint256 public teamFund = 400000000 * (10 ** 18);   
    uint256 public communityFund = 400000000 * (10 ** 18);   
    uint256 public marketingFund = 400000000 * (10 ** 18);   
    

    
    
    uint256 public totalTokenMintedAngel;
    uint256 public totalTokenMintedPreSale;
    uint256 public totalTokenMintedOpen;

    uint256 public totalTeamFundMinted;
    uint256 public totalCommunityFundMinted;
    uint256 public totalMarketingFundMinted;
    

    
    
    uint256 private _angelRate = 60000;
    uint256 private _preSaleRate = 30000;
    uint256 private _openRate = 20000;
    

    
    TokenTimelock public angelTimeLock;

    
    TokenVesting public teamTokenVesting;

    
    uint256 public constant TEAM_VESTING_CLIFF = 6 * 30 days;
    uint256 public constant TEAM_VESTING_DURATION = 2 years;

    ERC20 _token = new Circle();

    
    
    function CircleCrowdsale(uint256 _rate, address _wallet) public
    Crowdsale(_rate, _wallet, _token)
    {
    }
    

    function() external payable {
        revert();
    }

    function buyTokens(address _beneficiary) public payable {
        revert();
    }

    function investByLegalTender(address _beneficiary, uint256 _value, uint _stage) onlyOwner external returns (bool)  {
        uint256 _amount;
        if (_stage == uint(CrowdsaleStage.PreSaleRound)) {
            _amount = _preSaleRate * _value;
            if (totalTokenMintedPreSale + _amount > preSaleRound) {
                return false;
            }
            MintableToken(token).mint(_beneficiary, _amount);
            totalTokenMintedPreSale += _amount;
        } else if (_stage == uint(CrowdsaleStage.OpenRound)) {

            _amount = _openRate * _value;
            if (totalTokenMintedOpen + _amount > preSaleRound) {
                return false;
            }

            MintableToken(token).mint(_beneficiary, _amount);
            totalTokenMintedOpen += _amount;
        } else {
            return false;
        }

        return true;
    }

    function setAngelHolder(address _angelFundWallet) onlyOwner external {
        if (angelRound - totalTokenMintedAngel > 0) {
            angelTimeLock = new TokenTimelock(token, _angelFundWallet, uint64(now + 90 days));
            MintableToken(token).mint(angelTimeLock, angelRound - totalTokenMintedAngel);
            totalTokenMintedAngel = angelRound - totalTokenMintedAngel;
        }
    }

    function setReservedHolder(address _teamFundWallet, address _communityFundWallet, address _marketingFundWallet) onlyOwner external {
        if (teamFund - totalTeamFundMinted > 0) {
            teamTokenVesting = new TokenVesting(_teamFundWallet, now, TEAM_VESTING_CLIFF, TEAM_VESTING_DURATION, true);
            MintableToken(token).mint(teamTokenVesting, teamFund - totalTeamFundMinted);
            totalTeamFundMinted = teamFund - totalTeamFundMinted;
        }

        if (communityFund - totalCommunityFundMinted > 0) {
            MintableToken(token).mint(_communityFundWallet, communityFund - totalCommunityFundMinted);
            totalCommunityFundMinted += communityFund - totalCommunityFundMinted;
        }
        if (marketingFund - totalMarketingFundMinted > 0) {
            MintableToken(token).mint(_marketingFundWallet, marketingFund - totalMarketingFundMinted);
            totalMarketingFundMinted += marketingFund - totalMarketingFundMinted;
        }
    }

}