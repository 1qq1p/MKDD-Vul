


pragma solidity ^0.5.4;

interface IntVoteInterface {
    
    
    modifier onlyProposalOwner(bytes32 _proposalId) {revert(); _;}
    modifier votable(bytes32 _proposalId) {revert(); _;}

    event NewProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _numOfChoices,
        address _proposer,
        bytes32 _paramsHash
    );

    event ExecuteProposal(bytes32 indexed _proposalId,
        address indexed _organization,
        uint256 _decision,
        uint256 _totalReputation
    );

    event VoteProposal(
        bytes32 indexed _proposalId,
        address indexed _organization,
        address indexed _voter,
        uint256 _vote,
        uint256 _reputation
    );

    event CancelProposal(bytes32 indexed _proposalId, address indexed _organization );
    event CancelVoting(bytes32 indexed _proposalId, address indexed _organization, address indexed _voter);

    








    function propose(
        uint256 _numOfChoices,
        bytes32 _proposalParameters,
        address _proposer,
        address _organization
        ) external returns(bytes32);

    function vote(
        bytes32 _proposalId,
        uint256 _vote,
        uint256 _rep,
        address _voter
    )
    external
    returns(bool);

    function cancelVote(bytes32 _proposalId) external;

    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint256);

    function isVotable(bytes32 _proposalId) external view returns(bool);

    





    function voteStatus(bytes32 _proposalId, uint256 _choice) external view returns(uint256);

    



    function isAbstainAllow() external pure returns(bool);

    




    function getAllowedRangeOfChoices() external pure returns(uint256 min, uint256 max);
}



pragma solidity ^0.5.2;





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



pragma solidity ^0.5.4;


interface VotingMachineCallbacksInterface {
    function mintReputation(uint256 _amount, address _beneficiary, bytes32 _proposalId) external returns(bool);
    function burnReputation(uint256 _amount, address _owner, bytes32 _proposalId) external returns(bool);

    function stakingTokenTransfer(IERC20 _stakingToken, address _beneficiary, uint256 _amount, bytes32 _proposalId)
    external
    returns(bool);

    function getTotalReputationSupply(bytes32 _proposalId) external view returns(uint256);
    function reputationOf(address _owner, bytes32 _proposalId) external view returns(uint256);
    function balanceOfStakingToken(IERC20 _stakingToken, bytes32 _proposalId) external view returns(uint256);
}



pragma solidity ^0.5.2;






contract Redeemer {
    using SafeMath for uint;

    ContributionReward public contributionReward;
    GenesisProtocol public genesisProtocol;

    constructor(address _contributionReward, address _genesisProtocol) public {
        contributionReward = ContributionReward(_contributionReward);
        genesisProtocol = GenesisProtocol(_genesisProtocol);
    }

   



























    function redeem(bytes32 _proposalId, Avatar _avatar, address _beneficiary)
    external
    returns(uint[3] memory gpRewards,
            uint[2] memory gpDaoBountyReward,
            bool executed,
            uint256 winningVote,
            int256 crReputationReward,
            uint256 crNativeTokenReward,
            uint256 crEthReward,
            uint256 crExternalTokenReward)
    {
        GenesisProtocol.ProposalState pState = genesisProtocol.state(_proposalId);

        if ((pState == GenesisProtocolLogic.ProposalState.Queued)||
            (pState == GenesisProtocolLogic.ProposalState.PreBoosted)||
            (pState == GenesisProtocolLogic.ProposalState.Boosted)||
            (pState == GenesisProtocolLogic.ProposalState.QuietEndingPeriod)) {
            executed = genesisProtocol.execute(_proposalId);
        }
        pState = genesisProtocol.state(_proposalId);
        if ((pState == GenesisProtocolLogic.ProposalState.Executed) ||
            (pState == GenesisProtocolLogic.ProposalState.ExpiredInQueue)) {
            gpRewards = genesisProtocol.redeem(_proposalId, _beneficiary);
            (gpDaoBountyReward[0], gpDaoBountyReward[1]) = genesisProtocol.redeemDaoBounty(_proposalId, _beneficiary);
            winningVote = genesisProtocol.winningVote(_proposalId);
            
            if (contributionReward.getProposalExecutionTime(_proposalId, address(_avatar)) > 0) {
                (crReputationReward, crNativeTokenReward, crEthReward, crExternalTokenReward) =
                contributionRewardRedeem(_proposalId, _avatar);
            }
        }
    }

    function contributionRewardRedeem(bytes32 _proposalId, Avatar _avatar)
    private
    returns (int256 reputation, uint256 nativeToken, uint256 eth, uint256 externalToken)
    {
        bool[4] memory whatToRedeem;
        whatToRedeem[0] = true; 
        whatToRedeem[1] = true; 
        uint256 periodsToPay = contributionReward.getPeriodsToPay(_proposalId, address(_avatar), 2);
        uint256 ethReward = contributionReward.getProposalEthReward(_proposalId, address(_avatar));
        uint256 externalTokenReward = contributionReward.getProposalExternalTokenReward(_proposalId, address(_avatar));
        address externalTokenAddress = contributionReward.getProposalExternalToken(_proposalId, address(_avatar));
        ethReward = periodsToPay.mul(ethReward);
        if ((ethReward == 0) || (address(_avatar).balance < ethReward)) {
            whatToRedeem[2] = false;
        } else {
            whatToRedeem[2] = true;
        }
        periodsToPay = contributionReward.getPeriodsToPay(_proposalId, address(_avatar), 3);
        externalTokenReward = periodsToPay.mul(externalTokenReward);
        if ((externalTokenReward == 0) ||
            (IERC20(externalTokenAddress).balanceOf(address(_avatar)) < externalTokenReward)) {
            whatToRedeem[3] = false;
        } else {
            whatToRedeem[3] = true;
        }
        (reputation, nativeToken, eth, externalToken) = contributionReward.redeem(_proposalId, _avatar, whatToRedeem);
    }
}
