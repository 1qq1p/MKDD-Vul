pragma solidity ^0.4.18;
















contract HPPOToken is PausableToken {
    string  public  constant name = "HPPO";
    string  public  constant symbol = "HPPO";
    uint8   public  constant decimals = 18;

    modifier validDestination( address to )
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    constructor ( uint _totalTokenAmount ) public
    {

        totalSupply_ = _totalTokenAmount;
        balances[msg.sender] = _totalTokenAmount;
        emit Transfer(address(0x0), msg.sender, _totalTokenAmount);
    }

    
    function transfer(address _to, uint _value) public validDestination(_to) returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    
    function transferFrom(address _from, address _to, uint _value) public validDestination(_to) returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

   
     
    function burn(uint _value) public returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    
    function burnFrom(address _from, uint256 _value) public returns (bool) 
    {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

    
    function transferOwnership(address newOwner) public  {
        super.transferOwnership(newOwner);
    }

    
    function addTotalSupply(uint256 _value) public onlyOwner {
    	totalSupply_ = totalSupply_.add(_value);
    	balances[msg.sender]=balances[msg.sender].add(_value);
    	emit Transfer(address(0x0), msg.sender, _value);
    }
}