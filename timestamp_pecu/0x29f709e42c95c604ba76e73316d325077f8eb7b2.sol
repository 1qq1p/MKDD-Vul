pragma solidity >=0.4.25 <0.5.0;
library NMRSafeMath {
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
contract Shareable {
  struct PendingState {
    uint yetNeeded;
    uint ownersDone;
    uint index;
  }
  uint public required;
  address[256] owners;
  uint constant c_maxOwners = 250;
  mapping(address => uint) ownerIndex;
  mapping(bytes32 => PendingState) pendings;
  bytes32[] pendingsIndex;
  event Confirmation(address owner, bytes32 operation);
  event Revoke(address owner, bytes32 operation);
  address thisContract = this;
  modifier onlyOwner {
    if (isOwner(msg.sender))
      _;
  }
  modifier onlyManyOwners(bytes32 _operation) {
    if (confirmAndCheck(_operation))
      _;
  }
  function Shareable(address[] _owners, uint _required) {
    owners[1] = msg.sender;
    ownerIndex[msg.sender] = 1;
    for (uint i = 0; i < _owners.length; ++i) {
      owners[2 + i] = _owners[i];
      ownerIndex[_owners[i]] = 2 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }
  function changeShareable(address[] _owners, uint _required) onlyManyOwners(sha3(msg.data)) {
    for (uint i = 0; i < _owners.length; ++i) {
      owners[1 + i] = _owners[i];
      ownerIndex[_owners[i]] = 1 + i;
    }
    if (required > owners.length) throw;
    required = _required;
  }
  function revoke(bytes32 _operation) external {
    uint index = ownerIndex[msg.sender];
    if (index == 0) return;
    uint ownerIndexBit = 2**index;
    var pending = pendings[_operation];
    if (pending.ownersDone & ownerIndexBit > 0) {
      pending.yetNeeded++;
      pending.ownersDone -= ownerIndexBit;
      Revoke(msg.sender, _operation);
    }
  }
  function getOwner(uint ownerIndex) external constant returns (address) {
    return address(owners[ownerIndex + 1]);
  }
  function isOwner(address _addr) constant returns (bool) {
    return ownerIndex[_addr] > 0;
  }
  function hasConfirmed(bytes32 _operation, address _owner) constant returns (bool) {
    var pending = pendings[_operation];
    uint index = ownerIndex[_owner];
    if (index == 0) return false;
    uint ownerIndexBit = 2**index;
    return !(pending.ownersDone & ownerIndexBit == 0);
  }
  function confirmAndCheck(bytes32 _operation) internal returns (bool) {
    uint index = ownerIndex[msg.sender];
    if (index == 0) return;
    var pending = pendings[_operation];
    if (pending.yetNeeded == 0) {
      pending.yetNeeded = required;
      pending.ownersDone = 0;
      pending.index = pendingsIndex.length++;
      pendingsIndex[pending.index] = _operation;
    }
    uint ownerIndexBit = 2**index;
    if (pending.ownersDone & ownerIndexBit == 0) {
      Confirmation(msg.sender, _operation);
      if (pending.yetNeeded <= 1) {
        delete pendingsIndex[pendings[_operation].index];
        delete pendings[_operation];
        return true;
      }
      else
        {
          pending.yetNeeded--;
          pending.ownersDone |= ownerIndexBit;
        }
    }
  }
  function clearPending() internal {
    uint length = pendingsIndex.length;
    for (uint i = 0; i < length; ++i)
    if (pendingsIndex[i] != 0)
      delete pendings[pendingsIndex[i]];
    delete pendingsIndex;
  }
}
contract Safe {
    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
    function safeSubtract(uint a, uint b) internal returns (uint) {
        uint c = a - b;
        assert(b <= a && c <= a);
        return c;
    }
    function safeMultiply(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || (c / a) == b);
        return c;
    }
    function shrink128(uint a) internal returns (uint128) {
        assert(a < 0x100000000000000000000000000000000);
        return uint128(a);
    }
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length == numWords * 32 + 4);
        _;
    }
    function () payable { }
}
contract StoppableShareable is Shareable {
  bool public stopped;
  bool public stoppable = true;
  modifier stopInEmergency { if (!stopped) _; }
  modifier onlyInEmergency { if (stopped) _; }
  function StoppableShareable(address[] _owners, uint _required) Shareable(_owners, _required) {
  }
  function emergencyStop() external onlyOwner {
    assert(stoppable);
    stopped = true;
  }
  function release() external onlyManyOwners(sha3(msg.data)) {
    assert(stoppable);
    stopped = false;
  }
  function disableStopping() external onlyManyOwners(sha3(msg.data)) {
    stoppable = false;
  }
}
contract NumeraireShared is Safe {
    address public numerai = this;
    uint256 public supply_cap = 21000000e18; 
    uint256 public weekly_disbursement = 96153846153846153846153;
    uint256 public initial_disbursement;
    uint256 public deploy_time;
    uint256 public total_minted;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (uint => Tournament) public tournaments;  
    struct Tournament {
        uint256 creationTime;
        uint256[] roundIDs;
        mapping (uint256 => Round) rounds;  
    }
    struct Round {
        uint256 creationTime;
        uint256 endTime;
        uint256 resolutionTime;
        mapping (address => mapping (bytes32 => Stake)) stakes;  
    }
    struct Stake {
        uint128 amount; 
        uint128 confidence;
        bool successful;
        bool resolved;
    }
    event Mint(uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed staker, bytes32 tag, uint256 totalAmountStaked, uint256 confidence, uint256 indexed tournamentID, uint256 indexed roundID);
    event RoundCreated(uint256 indexed tournamentID, uint256 indexed roundID, uint256 endTime, uint256 resolutionTime);
    event TournamentCreated(uint256 indexed tournamentID);
    event StakeDestroyed(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag);
    event StakeReleased(uint256 indexed tournamentID, uint256 indexed roundID, address indexed stakerAddress, bytes32 tag, uint256 etherReward);
    function getMintable() constant returns (uint256) {
        return
            safeSubtract(
                safeAdd(initial_disbursement,
                    safeMultiply(weekly_disbursement,
                        safeSubtract(block.timestamp, deploy_time))
                    / 1 weeks),
                total_minted);
    }
}
contract NumeraireDelegateV3 is StoppableShareable, NumeraireShared {
    address public delegateContract;
    bool public contractUpgradable;
    address[] public previousDelegates;
    string public standard;
    string public name;
    string public symbol;
    uint256 public decimals;
    address private constant _RELAY = address(
        0xB17dF4a656505570aD994D023F632D48De04eDF2
    );
    event DelegateChanged(address oldAddress, address newAddress);
    using NMRSafeMath for uint256;
    constructor(address[] _owners, uint256 _num_required) public StoppableShareable(_owners, _num_required) {
        require(
            address(this) == address(0x29F709e42C95C604BA76E73316d325077f8eB7b2),
            "incorrect deployment address - check submitting account & nonce."
        );
    }
    function withdraw(address _from, address _to, uint256 _value) public returns(bool ok) {
        require(msg.sender == _RELAY);
        require(_to != address(0));
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    function createRound(uint256, uint256, uint256, uint256) public returns (bool ok) {
        require(msg.sender == _RELAY);
        require(contractUpgradable);
        contractUpgradable = false;
        return true;
    }
    function createTournament(uint256 _newDelegate) public returns (bool ok) {
        require(msg.sender == _RELAY);
        require(contractUpgradable);
        address newDelegate = address(_newDelegate);
        previousDelegates.push(delegateContract);
        emit DelegateChanged(delegateContract, newDelegate);
        delegateContract = newDelegate;
        return true;
    }
    function mint(uint256 _value) public returns (bool ok) {
        _burn(msg.sender, _value);
        return true;
    }
    function numeraiTransfer(address _to, uint256 _value) public returns (bool ok) {
        _burnFrom(_to, _value);
        return true;
    }
    function _burn(address _account, uint256 _value) internal {
        require(_account != address(0));
        totalSupply = totalSupply.sub(_value);
        balanceOf[_account] = balanceOf[_account].sub(_value);
        emit Transfer(_account, address(0), _value);
    }
    function _burnFrom(address _account, uint256 _value) internal {
        allowance[_account][msg.sender] = allowance[_account][msg.sender].sub(_value);
        _burn(_account, _value);
        emit Approval(_account, msg.sender, allowance[_account][msg.sender]);
    }
    function releaseStake(address, bytes32, uint256, uint256, uint256, bool) public pure returns (bool) {
        revert();
    }
    function destroyStake(address, bytes32, uint256, uint256) public pure returns (bool) {
        revert();
    }
    function stake(uint256, bytes32, uint256, uint256, uint256) public pure returns (bool) {
        revert();
    }
    function stakeOnBehalf(address, uint256, bytes32, uint256, uint256, uint256) public pure returns (bool) {
        revert();
    }
}