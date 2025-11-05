pragma solidity ^0.5.8;

library SafeMath
{
  	function mul(uint256 a, uint256 b) internal pure returns (uint256)
    	{
		uint256 c = a * b;
		assert(a == 0 || c / a == b);

		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a / b;

		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
		assert(b <= a);

		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		assert(c >= a);

		return c;
  	}
}

contract OwnerHelper
{
  	address public master;
  	address public owner1;
  	address public owner2;
  	
  	address public targetAddress;
  	uint public targetOwner;
    mapping (address => bool) public targetTransferOwnership;

  	event ChangeOwnerSuggest(address indexed _from, address indexed _to, uint indexed _num);

  	modifier onlyOwner
	{
		require(msg.sender == owner1 ||msg.sender == owner2);
		_;
  	}
  	
  	modifier onlyMaster
  	{
  	    require(msg.sender == master);
  	    _;
  	}
  	
  	constructor() public
	{
		master = msg.sender;
  	}
  	
  	function changeOwnership1(address _to) onlyMaster public
  	{
  	    require(_to != address(0x0));

  	    owner1 = _to;
  	}
  	
  	function changeOwnership2(address _to) onlyMaster public
  	{
  	    require(_to != address(0x0));
  	    
  	    owner2 = _to;
  	}
}
