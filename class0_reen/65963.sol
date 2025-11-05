pragma solidity ^0.4.23;




library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  


  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }





    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balances[_from] >= _value);
        
        require(balances[_to] + _value > balances[_to]);
        
        uint previousBalances = balances[_from] + balances[_to];
        
        balances[_from] = balances[_from].sub(_value);
        
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        
        assert(balances[_from] + balances[_to] == previousBalances);
    }

  




  function transfer(address _to, uint256 _value) public returns (bool) {
      _transfer(msg.sender, _to, _value);
      return true;
   








  }

  




  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}







