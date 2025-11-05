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








contract Reputation is Ownable {

    uint8 public decimals = 18;             
    
    event Mint(address indexed _to, uint256 _amount);
    
    event Burn(address indexed _from, uint256 _amount);

      
      
      
    struct Checkpoint {

    
        uint128 fromBlock;

          
        uint128 value;
    }

      
      
      
    mapping (address => Checkpoint[]) balances;

      
    Checkpoint[] totalSupplyHistory;

    
    constructor(
    ) public
    {
    }

    
    
    function totalSupply() public view returns (uint256) {
        return totalSupplyAt(block.number);
    }

  
  
  
    



    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

      
      
      
      
    function balanceOfAt(address _owner, uint256 _blockNumber)
    public view returns (uint256)
    {
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
          
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

      
      
      
    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
          
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

      
      
      
      
    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); 
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo); 
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_user], previousBalanceTo + _amount);
        emit Mint(_user, _amount);
        return true;
    }

      
      
      
      
    function burn(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        uint256 amountBurned = _amount;
        uint256 previousBalanceFrom = balanceOf(_user);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
        emit Burn(_user, amountBurned);
        return true;
    }

  
  
  

      
      
      
      
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block) internal view returns (uint256) {
        if (checkpoints.length == 0) {
            return 0;
        }

          
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

          
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

      
      
      
      
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        require(uint128(_value) == _value); 
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
        }
    }
}







library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}














