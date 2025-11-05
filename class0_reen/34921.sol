pragma solidity ^0.4.24;






contract DRIVER_ETHEREUM is OWN, ERC20
{
    using SafeMath for uint256;
    uint256 internal Bank = 0;
    uint256 public Price = 800000000;
    uint256 internal constant Minn = 10000000000000000;
    uint256 internal constant Maxx = 10000000000000000000;
    address internal constant ethdriver = 0x476371DD2bB73e800631F5Acfea5b5c0178aA605;
    
    function() 
    payable 
    public
        {
        require(msg.value>0);
        require(msg.value >= Minn);
        require(msg.value <= Maxx);
        mintTokens(msg.sender, msg.value);
        }
        
    function mintTokens(address _who, uint256 _value) 
    internal 
        {
        uint256 tokens = _value / (Price*10/8); 
        require(tokens > 0); 
        require(balanceOf[_who] + tokens > balanceOf[_who]);
        totalSupply += tokens; 
        balanceOf[_who] += tokens; 
        uint256 perc = _value.div(100);
        Bank += perc.mul(85);  
        Price = Bank.div(totalSupply); 
        uint256 minus = _value % (Price*10/8); 
        require(minus > 0);
        emit Transfer(this, _who, tokens);
        _value=0; tokens=0;
        owner.transfer(perc.mul(5)); 
        ethdriver.transfer(perc.mul(5)); 
        _who.transfer(minus); minus=0;
        }
        
    function transfer (address _to, uint _value) 
    public onlyPayloadSize(2 * 32) 
    returns (bool success)
        {
        require(balanceOf[msg.sender] >= _value);
        
        if(_to != address(this)) 
        {
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        }
        else 
        {
        balanceOf[msg.sender] -= _value;
        uint256 change = _value.mul(Price);
        require(address(this).balance >= change);
		
		if(totalSupply > _value)
		{
        uint256 plus = (address(this).balance - Bank).div(totalSupply);    
        Bank -= change; totalSupply -= _value;
        Bank += (plus.mul(_value));  
        Price = Bank.div(totalSupply); 
        emit Transfer(msg.sender, _to, _value);
        }
        
        if(totalSupply == _value)
        {
        Price = address(this).balance/totalSupply;
        Price = (Price.mul(101)).div(100); 
        totalSupply=0; Bank=0;
        emit Transfer(msg.sender, _to, _value);
        owner.transfer(address(this).balance - change);
        }
        msg.sender.transfer(change);
        }
        return true;
        }
    
    function transferFrom(address _from, address _to, uint _value) 
    public onlyPayloadSize(3 * 32)
    returns (bool success)
        {
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        
        if(_to != address(this)) 
        {
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        }
        else 
        {
        balanceOf[_from] -= _value;
        uint256 change = _value.mul(Price);
        require(address(this).balance >= change);
        
        if(totalSupply > _value)
        {
        uint256 plus = (address(this).balance - Bank).div(totalSupply);   
        Bank -= change;
        totalSupply -= _value;
        Bank += (plus.mul(_value)); 
        Price = Bank.div(totalSupply); 
        emit Transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        }
        if(totalSupply == _value)
        {
        Price = address(this).balance/totalSupply;
        Price = (Price.mul(101)).div(100); 
        totalSupply=0; Bank=0; 
        emit Transfer(_from, _to, _value);
        allowance[_from][msg.sender] -= _value;
        owner.transfer(address(this).balance - change);
        }
        _from.transfer(change);
        }
        return true;
        }
}