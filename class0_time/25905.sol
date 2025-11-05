pragma solidity ^0.5.2;






contract RELCoin is Pausable, DetailedERC20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  address public crowdsaleContract;
  uint256 public tokenSaled = 0;

  constructor(string memory _name, string memory _symbol, uint8 _decimals)
    DetailedERC20(_name, _symbol, _decimals)
    Ownable()
    public {
        totalSupply = 100 * (10**9) * 10**uint256(decimals);  
    }

  function setCrowdsaleContract(address crowdsale) onlyOwner public {
    crowdsaleContract = crowdsale;
  }

  function addToBalances(address _person,uint256 value) public returns (bool) {
    require(msg.sender == crowdsaleContract);
    require(value <= totalSupply - tokenSaled);
    balances[_person] = balances[_person].add(value);
    tokenSaled = tokenSaled.add(value);
    emit Transfer(address(this), _person, value);
    return true;
  }

  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }


  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}