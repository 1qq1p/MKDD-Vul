pragma solidity ^0.5.2;



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








contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    



    function when() public returns(CallPhase);
}









interface ControllerInterface {

    





    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    returns(bool);

    





    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    returns(bool);

    






    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    returns(bool);

  







    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    returns(bool);

    





    function unregisterScheme(address _scheme, address _avatar)
    external
    returns(bool);

    




    function unregisterSelf(address _avatar) external returns(bool);

    






    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external returns(bool);

    





    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external  returns(bool);

  






    function upgradeController(address _newController, Avatar _avatar)
    external returns(bool);

    







    function genericCall(address _contract, bytes calldata _data, Avatar _avatar)
    external
    returns(bool, bytes memory);

  






    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external returns(bool);

    







    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    










    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    returns(bool);

    







    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    




    function getNativeReputation(address _avatar)
    external
    view
    returns(address);

    function isSchemeRegistered( address _scheme, address _avatar) external view returns(bool);

    function getSchemeParameters(address _scheme, address _avatar) external view returns(bytes32);

    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32);

    function getSchemePermissions(address _scheme, address _avatar) external view returns(bytes4);

    




    function globalConstraintsCount(address _avatar) external view returns(uint, uint);

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar) external view returns(bool);
}


