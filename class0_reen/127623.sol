


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



pragma solidity ^0.5.0;





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



pragma solidity ^0.5.0;






contract GenericScheme is UniversalScheme, VotingMachineCallbacks, ProposalExecuteInterface {
    event NewCallProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        bytes   _callData,
        uint256 _value,
        string  _descriptionHash
    );

    event ProposalExecuted(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        bytes _genericCallReturnValue
    );

    event ProposalExecutedByVotingMachine(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        int256 _param
    );

    event ProposalDeleted(address indexed _avatar, bytes32 indexed _proposalId);

    
    struct CallProposal {
        bytes callData;
        uint256 value;
        bool exist;
        bool passed;
    }

    
    mapping(address=>mapping(bytes32=>CallProposal)) public organizationsProposals;

    struct Parameters {
        IntVoteInterface intVote;
        bytes32 voteParams;
        address contractToCall;
    }

    
    mapping(bytes32=>Parameters) public parameters;

    





    function executeProposal(bytes32 _proposalId, int256 _decision)
    external
    onlyVotingMachine(_proposalId)
    returns(bool) {
        Avatar avatar = proposalsInfo[msg.sender][_proposalId].avatar;
        CallProposal storage proposal = organizationsProposals[address(avatar)][_proposalId];
        require(proposal.exist, "must be a live proposal");
        require(proposal.passed == false, "cannot execute twice");

        if (_decision == 1) {
            proposal.passed = true;
            execute(avatar, _proposalId);
        } else {
            delete organizationsProposals[address(avatar)][_proposalId];
            emit ProposalDeleted(address(avatar), _proposalId);
        }

        emit ProposalExecutedByVotingMachine(address(avatar), _proposalId, _decision);
        return true;
    }

    



    function execute(Avatar _avatar, bytes32 _proposalId) public {
        Parameters memory params = parameters[getParametersFromController(_avatar)];
        CallProposal storage proposal = organizationsProposals[address(_avatar)][_proposalId];
        require(proposal.exist, "must be a live proposal");
        require(proposal.passed, "proposal must passed by voting machine");
        proposal.exist = false;
        bytes memory genericCallReturnValue;
        bool success;
        ControllerInterface controller = ControllerInterface(_avatar.owner());
        (success, genericCallReturnValue) =
        controller.genericCall(params.contractToCall, proposal.callData, _avatar, proposal.value);
        if (success) {
            delete organizationsProposals[address(_avatar)][_proposalId];
            emit ProposalDeleted(address(_avatar), _proposalId);
            emit ProposalExecuted(address(_avatar), _proposalId, genericCallReturnValue);
        } else {
            proposal.exist = true;
        }
    }

    





    function setParameters(
        bytes32 _voteParams,
        IntVoteInterface _intVote,
        address _contractToCall
    ) public returns(bytes32)
    {
        bytes32 paramsHash = getParametersHash(_voteParams, _intVote, _contractToCall);
        parameters[paramsHash].voteParams = _voteParams;
        parameters[paramsHash].intVote = _intVote;
        parameters[paramsHash].contractToCall = _contractToCall;
        return paramsHash;
    }

    





    function getParametersHash(
        bytes32 _voteParams,
        IntVoteInterface _intVote,
        address _contractToCall
    ) public pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(_voteParams, _intVote, _contractToCall));
    }

    








    function proposeCall(Avatar _avatar, bytes memory _callData, uint256 _value, string memory _descriptionHash)
    public
    returns(bytes32)
    {
        Parameters memory params = parameters[getParametersFromController(_avatar)];
        IntVoteInterface intVote = params.intVote;

        bytes32 proposalId = intVote.propose(2, params.voteParams, msg.sender, address(_avatar));

        organizationsProposals[address(_avatar)][proposalId] = CallProposal({
            callData: _callData,
            value: _value,
            exist: true,
            passed: false
        });
        proposalsInfo[address(params.intVote)][proposalId] = ProposalInfo({
            blockNumber:block.number,
            avatar:_avatar
        });
        emit NewCallProposal(address(_avatar), proposalId, _callData, _value, _descriptionHash);
        return proposalId;
    }

    





    function getContractToCall(Avatar _avatar) public view returns(address) {
        return parameters[getParametersFromController(_avatar)].contractToCall;
    }

}
