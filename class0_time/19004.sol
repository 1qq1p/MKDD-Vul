pragma solidity ^0.4.18;















library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

contract MultiOwner {
    
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
	event RequirementChanged(uint256 newRequirement);
	
    uint256 public ownerRequired;
    mapping (address => bool) public isOwner;
	mapping (address => bool) public RequireDispose;
	address[] owners;
	
	function MultiOwner(address[] _owners, uint256 _required) public {
        ownerRequired = _required;
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        
        for (uint256 i = 0; i < _owners.length; ++i){
			require(!isOwner[_owners[i]]);
			isOwner[_owners[i]] = true;
			owners.push(_owners[i]);
        }
    }
    
	modifier onlyOwner {
	    require(isOwner[msg.sender]);
        _;
    }
    
	modifier ownerDoesNotExist(address owner) {
		require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
		require(isOwner[owner]);
        _;
    }
    
    function addOwner(address owner) onlyOwner ownerDoesNotExist(owner) external{
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAdded(owner);
    }
    
	function numberOwners() public constant returns (uint256 NumberOwners){
	    NumberOwners = owners.length;
	}
	
    function removeOwner(address owner) onlyOwner ownerExists(owner) external{
		require(owners.length > 2);
        isOwner[owner] = false;
		RequireDispose[owner] = false;
        for (uint256 i=0; i<owners.length - 1; i++){
            if (owners[i] == owner) {
				owners[i] = owners[owners.length - 1];
                break;
            }
		}
		owners.length -= 1;
        OwnerRemoved(owner);
    }
    
	function changeRequirement(uint _newRequired) onlyOwner external {
		require(_newRequired >= owners.length);
        ownerRequired = _newRequired;
        RequirementChanged(_newRequired);
    }
	
	function ConfirmDispose() onlyOwner() public view returns (bool){
		uint count = 0;
		for (uint i=0; i<owners.length - 1; i++)
            if (RequireDispose[owners[i]])
                count += 1;
            if (count == ownerRequired)
                return true;
	}
	
	function kill() onlyOwner() public{
		RequireDispose[msg.sender] = true;
		if(ConfirmDispose()){
			selfdestruct(msg.sender);
		}
    }
}

interface ERC20{
    function transfer(address _to, uint _value, bytes _data) public;
    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value, bool _feed, uint256 _fees) public returns (bool success);
    function setPrices(uint256 newValue) public;
    function freezeAccount(address target, bool freeze) public;
    function() payable public;
	function remainBalanced() public constant returns (uint256);
	function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r);
	function isConfirmed(bytes32 TransHash) public constant returns (bool);
	function confirmationCount(bytes32 TransHash) external constant returns (uint count);
    function confirmTransaction(bytes32 TransHash) public;
    function executeTransaction(bytes32 TransHash) public;
	function AccountVoid(address _from) public;
	function burn(uint amount) public;
	function bonus(uint amount) public;
    
    event SubmitTransaction(bytes32 transactionHash);
	event Confirmation(address sender, bytes32 transactionHash);
	event Execution(bytes32 transactionHash);
	event FrozenFunds(address target, bool frozen);
    event Transfer(address indexed from, address indexed to, uint value);
	event FeePaid(address indexed from, address indexed to, uint256 value);
	event VoidAccount(address indexed from, address indexed to, uint256 value);
	event Bonus(uint256 value);
	event Burn(uint256 value);
}

interface ERC223 {
    function transfer(address to, uint value, bytes data) public;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
