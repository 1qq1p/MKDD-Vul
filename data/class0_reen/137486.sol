pragma solidity ^0.4.16;

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

contract Token is ERC20Interface {
    
    using SafeMath for uint;
    
    string public constant symbol = "LNC";
    string public constant name = "Linker Coin";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 500000000000000000000000000;
    
    
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
  
    
    
    address public owner;

    
    mapping(address => uint256) balances;

    
    mapping(address => mapping (address => uint256)) allowed;

    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function IsFreezedAccount(address _addr) public constant returns (bool) {
        return frozenAccount[_addr];
    }

    
    function Token() public {
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    function totalSupply() public constant returns (uint256 supply) {
        supply = _totalSupply;
    }

    
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        if (_to != 0x0  
            && IsFreezedAccount(msg.sender) == false
            && balances[msg.sender] >= _value 
            && _value > 0
            && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    
    
    
    
    
    
    function transferFrom(address _from,address _to, uint256 _value) public returns (bool success) {
        if (_to != 0x0  
            && IsFreezedAccount(_from) == false
            && balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
            && balances[_to] + _value > balances[_to]) {
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

     
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function FreezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
}
 