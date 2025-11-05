pragma solidity 0.4.22;






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
    
    uint256 c = a / b;
    
    return c;
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






contract MIOTToken is MintableToken, Pausable {
     string public name ;
     string public symbol ;
     uint8 public decimals = 18 ;
     
     


     function ()public payable {
         revert();
     }
     
     





     function MIOTToken(
            uint256 initialSupply,
            string tokenName,
            string tokenSymbol
         ) public {
         totalSupply = initialSupply.mul( 10 ** uint256(decimals)); 
         name = tokenName;
         symbol = tokenSymbol;
         balances[msg.sender] = totalSupply;
         
         
         Transfer(address(0), msg.sender, totalSupply);
     }
     
     


    function getTokenDetail() public view returns (string, string, uint256) {
	    return (name, symbol, totalSupply);
    }
    
     function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
  
    function mint(address _to, uint256 _amount)  public whenNotPaused returns (bool) {
    return super.mint(_to, _amount);
  }

  
 }