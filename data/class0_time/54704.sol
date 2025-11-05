pragma solidity ^0.4.17;

















contract FundingVault {

    
    bool public _initialized = false;

    





    address public vaultOwner ;
    address public outputAddress;
    address public managerAddress;

    



    bool public allFundingProcessed = false;
    bool public DirectFundingProcessed = false;

    


    
    ABIFunding FundingEntity;
    ABIFundingManager FundingManagerEntity;
    ABIMilestones MilestonesEntity;
    ABIProposals ProposalsEntity;
    ABITokenSCADAVariable TokenSCADAEntity;
    ABIToken TokenEntity ;

    


    uint256 public amount_direct = 0;
    uint256 public amount_milestone = 0;

    
    bool public emergencyFundReleased = false;
    uint8 emergencyFundPercentage = 0;
    uint256 BylawsCashBackOwnerMiaDuration;
    uint256 BylawsCashBackVoteRejectedDuration;
    uint256 BylawsProposalVotingDuration;

    struct PurchaseStruct {
        uint256 unix_time;
        uint8 payment_method;
        uint256 amount;
        uint8 funding_stage;
        uint16 index;
    }

    mapping(uint16 => PurchaseStruct) public purchaseRecords;
    uint16 public purchaseRecordsNum;

    event EventPaymentReceived(uint8 indexed _payment_method, uint256 indexed _amount, uint16 indexed _index );
    event VaultInitialized(address indexed _owner);

    function initialize(
        address _owner,
        address _output,
        address _fundingAddress,
        address _milestoneAddress,
        address _proposalsAddress
    )
        public
        requireNotInitialised
        returns(bool)
    {
        VaultInitialized(_owner);

        outputAddress = _output;
        vaultOwner = _owner;

        
        managerAddress = msg.sender;

        
        FundingEntity = ABIFunding(_fundingAddress);
        FundingManagerEntity = ABIFundingManager(managerAddress);
        MilestonesEntity = ABIMilestones(_milestoneAddress);
        ProposalsEntity = ABIProposals(_proposalsAddress);

        address TokenManagerAddress = FundingEntity.getApplicationAssetAddressByName("TokenManager");
        ABITokenManager TokenManagerEntity = ABITokenManager(TokenManagerAddress);

        address TokenAddress = TokenManagerEntity.TokenEntity();
        TokenEntity = ABIToken(TokenAddress);

        address TokenSCADAAddress = TokenManagerEntity.TokenSCADAEntity();
        TokenSCADAEntity = ABITokenSCADAVariable(TokenSCADAAddress);

        
        address ApplicationEntityAddress = TokenManagerEntity.owner();
        ApplicationEntityABI ApplicationEntity = ApplicationEntityABI(ApplicationEntityAddress);

        
        emergencyFundPercentage             = uint8( ApplicationEntity.getBylawUint256("emergency_fund_percentage") );
        BylawsCashBackOwnerMiaDuration      = ApplicationEntity.getBylawUint256("cashback_owner_mia_dur") ;
        BylawsCashBackVoteRejectedDuration  = ApplicationEntity.getBylawUint256("cashback_investor_no") ;
        BylawsProposalVotingDuration        = ApplicationEntity.getBylawUint256("proposal_voting_duration") ;

        
        _initialized = true;
        return true;
    }



    




    mapping (uint8 => uint256) public stageAmounts;
    mapping (uint8 => uint256) public stageAmountsDirect;

    function addPayment(
        uint8 _payment_method,
        uint8 _funding_stage
    )
        public
        payable
        requireInitialised
        onlyManager
        returns (bool)
    {
        if(msg.value > 0 && FundingEntity.allowedPaymentMethod(_payment_method)) {

            
            PurchaseStruct storage purchase = purchaseRecords[++purchaseRecordsNum];
                purchase.unix_time = now;
                purchase.payment_method = _payment_method;
                purchase.amount = msg.value;
                purchase.funding_stage = _funding_stage;
                purchase.index = purchaseRecordsNum;

            
            if(_payment_method == 1) {
                amount_direct+= purchase.amount;
                stageAmountsDirect[_funding_stage]+=purchase.amount;
            }

            if(_payment_method == 2) {
                amount_milestone+= purchase.amount;
            }

            
            
            
            
            
            stageAmounts[_funding_stage]+=purchase.amount;

            EventPaymentReceived( purchase.payment_method, purchase.amount, purchase.index );
            return true;
        } else {
            revert();
        }
    }

    function getBoughtTokens() public view returns (uint256) {
        return TokenSCADAEntity.getBoughtTokens( address(this), false );
    }

    function getDirectBoughtTokens() public view returns (uint256) {
        return TokenSCADAEntity.getBoughtTokens( address(this), true );
    }


    mapping (uint8 => uint256) public etherBalances;
    mapping (uint8 => uint256) public tokenBalances;
    uint8 public BalanceNum = 0;

    bool public BalancesInitialised = false;
    function initMilestoneTokenAndEtherBalances() internal
    {
        if(BalancesInitialised == false) {

            uint256 milestoneTokenBalance = TokenEntity.balanceOf(address(this));
            uint256 milestoneEtherBalance = this.balance;

            

            
            if(emergencyFundPercentage > 0) {
                tokenBalances[0] = milestoneTokenBalance / 100 * emergencyFundPercentage;
                etherBalances[0] = milestoneEtherBalance / 100 * emergencyFundPercentage;

                milestoneTokenBalance-=tokenBalances[0];
                milestoneEtherBalance-=etherBalances[0];
            }

            
            for(uint8 i = 1; i <= MilestonesEntity.RecordNum(); i++) {

                uint8 perc = MilestonesEntity.getMilestoneFundingPercentage(i);
                tokenBalances[i] = milestoneTokenBalance / 100 * perc;
                etherBalances[i] = milestoneEtherBalance / 100 * perc;
            }

            BalanceNum = i;
            BalancesInitialised = true;
        }
    }

    function ReleaseFundsAndTokens()
        public
        requireInitialised
        onlyManager
        returns (bool)
    {
        
        if(!canCashBack() && allFundingProcessed == false) {

            if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("FUNDING_SUCCESSFUL_PROGRESS")) {

                
                if(amount_direct > 0 && amount_milestone == 0) {

                    
                    

                    
                    TokenEntity.transfer(vaultOwner, TokenEntity.balanceOf( address(this) ) );

                    
                    outputAddress.transfer(this.balance);

                    
                    allFundingProcessed = true;

                } else {
                

                    if(amount_direct > 0 && DirectFundingProcessed == false ) {
                        TokenEntity.transfer(vaultOwner, getDirectBoughtTokens() );
                        
                        outputAddress.transfer(amount_direct);
                        DirectFundingProcessed = true;
                    }

                    
                    initMilestoneTokenAndEtherBalances();
                }
                return true;

            } else if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("MILESTONE_PROCESS_PROGRESS")) {

                
                uint8 milestoneId = MilestonesEntity.currentRecord();

                uint256 transferTokens = tokenBalances[milestoneId];
                uint256 transferEther = etherBalances[milestoneId];

                if(milestoneId == BalanceNum - 1) {
                    
                    
                    
                    transferTokens = TokenEntity.balanceOf(address(this));
                    transferEther = this.balance;
                }

                
                
                

                
                TokenEntity.transfer(vaultOwner, transferTokens );

                
                outputAddress.transfer(transferEther);

                if(milestoneId == BalanceNum - 1) {
                    
                    allFundingProcessed = true;
                }

                return true;
            }
        }

        return false;
    }


    function releaseTokensAndEtherForEmergencyFund()
        public
        requireInitialised
        onlyManager
        returns (bool)
    {
        if( emergencyFundReleased == false && emergencyFundPercentage > 0) {

            
            TokenEntity.transfer(vaultOwner, tokenBalances[0] );

            
            outputAddress.transfer(etherBalances[0]);

            emergencyFundReleased = true;
            return true;
        }
        return false;
    }

    function ReleaseFundsToInvestor()
        public
        requireInitialised
        isOwner
    {
        if(canCashBack()) {

            
            
            

            
            uint256 myBalance = TokenEntity.balanceOf(address(this));
            
            if(myBalance > 0) {
                TokenEntity.transfer(outputAddress, myBalance );
            }

            
            vaultOwner.transfer(this.balance);

            
            FundingManagerEntity.VaultRequestedUpdateForLockedVotingTokens( vaultOwner );

            
            
            allFundingProcessed = true;
        }
    }

    






    function canCashBack() public view requireInitialised returns (bool) {

        
        if(checkFundingStateFailed()) {
            return true;
        }
        
        if(checkMilestoneStateInvestorVotedNoVotingEndedNo()) {
            return true;
        }
        
        if(checkOwnerFailedToSetTimeOnMeeting()) {
            return true;
        }

        return false;
    }

    function checkFundingStateFailed() public view returns (bool) {
        if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("FAILED_FINAL") ) {
            return true;
        }

        
        if( FundingEntity.getTimestamp() >= FundingEntity.Funding_Setting_cashback_time_start() ) {

            
            if( FundingEntity.CurrentEntityState() != FundingEntity.getEntityState("SUCCESSFUL_FINAL") ) {
                return true;
            }
        }

        return false;
    }

    function checkMilestoneStateInvestorVotedNoVotingEndedNo() public view returns (bool) {
        if(MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("VOTING_ENDED_NO") ) {
            
            if( ProposalsEntity.getHasVoteForCurrentMilestoneRelease(vaultOwner) == true) {
                
                if( ProposalsEntity.getMyVoteForCurrentMilestoneRelease( vaultOwner ) == false) {
                    return true;
                }
            }
        }
        return false;
    }

    function checkOwnerFailedToSetTimeOnMeeting() public view returns (bool) {
        
        
        

        
        if( MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("DEADLINE_MEETING_TIME_FAILED") ) {
            return true;
        }
        return false;
    }


    modifier isOwner() {
        require(msg.sender == vaultOwner);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == managerAddress);
        _;
    }

    modifier requireInitialised() {
        require(_initialized == true);
        _;
    }

    modifier requireNotInitialised() {
        require(_initialized == false);
        _;
    }
}


























