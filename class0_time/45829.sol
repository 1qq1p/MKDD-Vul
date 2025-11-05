pragma solidity ^0.4.24;

contract ERC20Token is ERC20,ERC20Ownable {
    
    mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	
    event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value
		);

	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
		);
		
	
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	}

	function balanceOf(address _owner) constant public returns (uint256) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) onlyPayloadSize(2*32) public returns (bool){
		require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] -= _value;
	    balances[_to] += _value;
	    emit Transfer(msg.sender, _to, _value);
	    return true;
    }

	function transferFrom(address _from, address _to, uint256 _value) public {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }

	function approve(address _spender, uint256 _value) public {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        
        
        
        
        require(_spender.call(abi.encodeWithSelector(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")),msg.sender, _value, this, _extraData)));

        return true;
    }
    
	function allowance(address _owner, address _spender) constant public returns (uint256) {
		return allowed[_owner][_spender];
	}
}
