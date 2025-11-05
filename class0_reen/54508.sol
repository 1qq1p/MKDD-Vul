pragma solidity ^0.4.13;


contract QKL is ERC20,Pausable{
	using SafeMath for uint256;

	string public constant name="QKL";
	string public symbol="QKL";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;
	uint256 public totalSupply;

	uint256 public constant INIT_SUPPLY=10000000000*10**decimals;

	
    struct epoch  {
        uint256 lockEndTime;
        uint256 lockAmount;
    }

    mapping(address=>epoch[]) public lockEpochsMap;

	
    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	event GetETH(address indexed _from, uint256 _value);
	event Burn(address indexed burner, uint256 value);

	
	function QKL(){
		totalSupply=INIT_SUPPLY;
		balances[msg.sender] = INIT_SUPPLY;
		Transfer(0x0, msg.sender, INIT_SUPPLY);
	}
    


    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

  	
	function lockBalance(address user, uint256 lockAmount,uint256 lockEndTime) external
		onlyOwner
	{
		 epoch[] storage epochs = lockEpochsMap[user];
		 epochs.push(epoch(lockEndTime,lockAmount));
	}

	
	function () payable external
	{
		GetETH(msg.sender,msg.value);
	}

	function etherProceeds() external
		onlyOwner
	{
		if(!msg.sender.send(this.balance)) revert();
	}

  	function transfer(address _to, uint256 _value) whenNotPaused  public  returns (bool)
 	{
		require(_to != address(0));

		
		epoch[] epochs = lockEpochsMap[msg.sender];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance=needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[msg.sender].sub(_value)>=needLockBalance);

		
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public constant returns (uint256 balance) 
  	{
		return balances[_owner];
  	}

  	function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) 
  	{
		require(_to != address(0));

		
		epoch[] epochs = lockEpochsMap[_from];
		uint256 needLockBalance = 0;
		for(uint256 i = 0;i<epochs.length;i++)
		{
			
			if( now < epochs[i].lockEndTime )
			{
				needLockBalance = needLockBalance.add(epochs[i].lockAmount);
			}
		}

		require(balances[_from].sub(_value)>=needLockBalance);

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}

	  
}