pragma solidity ^0.4.23;






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





contract StandardToken is ERC20{
  
   
   
   using SafeMath for uint256; 
       
  


  modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4) ;
    _;
  }

  mapping(address => uint) accountBalances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32)  returns (bool success){
    accountBalances[msg.sender] = accountBalances[msg.sender].sub(_value);
    accountBalances[_to] = accountBalances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    accountBalances[_to] = accountBalances[_to].add(_value);
    accountBalances[_from] = accountBalances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return accountBalances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}


