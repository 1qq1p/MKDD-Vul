pragma solidity ^0.4.12;








library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract BurnableToken is StandardToken {
    using SafeMath for uint256;

    event Burn(address indexed from, uint256 amount);
    event BurnRewardIncreased(address indexed from, uint256 value);

    


    function() payable {
        if(msg.value > 0){
            BurnRewardIncreased(msg.sender, msg.value);    
        }
    }

    



    function burnReward(uint256 _amount) public constant returns(uint256){
        return this.balance.mul(_amount).div(totalSupply);
    }

    







    function burn(address _from, uint256 _amount) internal returns(bool){
        require(balances[_from] >= _amount);
        
        uint256 reward = burnReward(_amount);
        assert(this.balance - reward > 0);

        balances[_from] = balances[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        
        
        _from.transfer(reward);
        Transfer(_from, 0x0, _amount);
        Burn(_from, _amount);
        return true;
    }

    





    function transfer(address _to, uint256 _value) returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            return burn(msg.sender, _value);
        }else{
            return super.transfer(_to, _value);
        }
    }

    






    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        if( (_to == address(this)) || (_to == 0) ){
            var _allowance = allowed[_from][msg.sender];
            
            allowed[_from][msg.sender] = _allowance.sub(_value);
            return burn(_from, _value);
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }

}



