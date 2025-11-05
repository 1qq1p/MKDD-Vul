pragma solidity ^0.4.20;




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
contract NPLAY is ERC20 {
    
    uint256 activeUsers;

    mapping(address => bool) isRegistered;
    mapping(address => uint256) accountID;
    mapping(uint256 => address) accountFromID;
    mapping(address => bool) isTrusted;

    event Burn(address _from,uint256 _value);
    
    modifier isTrustedContract{
        require(isTrusted[msg.sender]);
        _;
    }
    
    modifier registered{
        require(isRegistered[msg.sender]);
        _;
    }
    
    constructor(
        string tokenName,
        string tokenSymbol) public payable
        ERC20(74145513585,tokenName,tokenSymbol)
    {
       
    }
    
    function distribute(address[] users,uint256[] balances) public onlyOwner {
         uint i;
        for(i = 0;i <users.length;i++){
            transferFrom(owner,users[i],balances[i]);
        }
    }

    function burnFrom(address _from, uint256 _value) internal returns (bool success) {
        require(_from == msg.sender || _from == owner);
        require(balances[_from] >= _value);
        balances[_from] = SafeMath.sub(balances[_from],_value);
        totalSupply = SafeMath.sub(totalSupply,_value);
        emit Burn(_from, _value);
        return true;
    }

    function contractBurn(address _for,uint256 value)external isTrustedContract{
        burnFrom(_for,value);
    }

    function burn(uint256 val)public{
        burnFrom(msg.sender,val);
    }

    function registerAccount(address user)internal{
        if(!isRegistered[user]){
            isRegistered[user] = true;
            activeUsers += 1;
            accountID[user] = activeUsers;
            accountFromID[activeUsers] = user;
        }
    }
    
    function registerExternal()external{
        registerAccount(msg.sender);
    }
    
    function register() public {
        registerAccount(msg.sender);
    }

    function testConnection() external {
        emit Log("CONNECTED");
    }
}