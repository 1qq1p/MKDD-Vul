pragma solidity >=0.5.4 <0.6.0;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }






library SafeMath {

	


	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		
		
		
		if (a == 0) {
			return 0;
		}

		c = a * b;
		assert(c / a == b);
		return c;
	}

	


	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		
		
		return a / b;
	}

	


	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	


	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}


interface INameTAOPosition {
	function senderIsAdvocate(address _sender, address _id) external view returns (bool);
	function senderIsListener(address _sender, address _id) external view returns (bool);
	function senderIsSpeaker(address _sender, address _id) external view returns (bool);
	function senderIsPosition(address _sender, address _id) external view returns (bool);
	function getAdvocate(address _id) external view returns (address);
	function nameIsAdvocate(address _nameId, address _id) external view returns (bool);
	function nameIsPosition(address _nameId, address _id) external view returns (bool);
	function initialize(address _id, address _advocateId, address _listenerId, address _speakerId) external returns (bool);
	function determinePosition(address _sender, address _id) external view returns (uint256);
}















contract TAOCurrency is TheAO {
	using SafeMath for uint256;

	
	string public name;
	string public symbol;
	uint8 public decimals;

	
	uint256 public powerOfTen;

	uint256 public totalSupply;

	
	
	mapping (address => uint256) public balanceOf;

	
	
	event Transfer(address indexed from, address indexed to, uint256 value);

	
	
	event Burn(address indexed from, uint256 value);

	




	constructor (string memory _name, string memory _symbol, address _nameTAOPositionAddress) public {
		name = _name;		
		symbol = _symbol;	

		powerOfTen = 0;
		decimals = 0;

		setNameTAOPositionAddress(_nameTAOPositionAddress);
	}

	




	modifier onlyTheAO {
		require (AOLibrary.isTheAO(msg.sender, theAO, nameTAOPositionAddress));
		_;
	}

	


	modifier isNameOrTAO(address _id) {
		require (AOLibrary.isName(_id) || AOLibrary.isTAO(_id));
		_;
	}

	
	



	function transferOwnership(address _theAO) public onlyTheAO {
		require (_theAO != address(0));
		theAO = _theAO;
	}

	




	function setWhitelist(address _account, bool _whitelist) public onlyTheAO {
		require (_account != address(0));
		whitelist[_account] = _whitelist;
	}

	



	function setNameTAOPositionAddress(address _nameTAOPositionAddress) public onlyTheAO {
		require (_nameTAOPositionAddress != address(0));
		nameTAOPositionAddress = _nameTAOPositionAddress;
	}

	
	








	function transferFrom(address _from, address _to, uint256 _value) public inWhitelist isNameOrTAO(_from) isNameOrTAO(_to) returns (bool) {
		_transfer(_from, _to, _value);
		return true;
	}

	





	function mint(address target, uint256 mintedAmount) public inWhitelist isNameOrTAO(target) returns (bool) {
		_mint(target, mintedAmount);
		return true;
	}

	






	function whitelistBurnFrom(address _from, uint256 _value) public inWhitelist isNameOrTAO(_from) returns (bool success) {
		require(balanceOf[_from] >= _value);                
		balanceOf[_from] = balanceOf[_from].sub(_value);    
		totalSupply = totalSupply.sub(_value);              
		emit Burn(_from, _value);
		return true;
	}

	
	





	function _transfer(address _from, address _to, uint256 _value) internal {
		require (_to != address(0));							
		require (balanceOf[_from] >= _value);					
		require (balanceOf[_to].add(_value) >= balanceOf[_to]); 
		uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
		balanceOf[_from] = balanceOf[_from].sub(_value);        
		balanceOf[_to] = balanceOf[_to].add(_value);            
		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
	}

	




	function _mint(address target, uint256 mintedAmount) internal {
		balanceOf[target] = balanceOf[target].add(mintedAmount);
		totalSupply = totalSupply.add(mintedAmount);
		emit Transfer(address(0), address(this), mintedAmount);
		emit Transfer(address(this), target, mintedAmount);
	}
}

