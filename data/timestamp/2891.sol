pragma solidity ^0.4.18;












contract RxEALTokenContract is StandardToken {

  

  
  string public constant name = "RxEAL";
  string public constant symbol = "RXL";
  uint256 public constant decimals = 18;

  

  
  
  uint256 public constant INITIAL_SUPPLY = 96000000 * (10 ** decimals);
  
  address public vault = this;
  
  address public salesAgent;
  
  mapping (address => bool) public owners;

  

  
  event OwnershipGranted(address indexed _owner, address indexed revoked_owner);
  event OwnershipRevoked(address indexed _owner, address indexed granted_owner);
  event SalesAgentPermissionsTransferred(address indexed previousSalesAgent, address indexed newSalesAgent);
  event SalesAgentRemoved(address indexed currentSalesAgent);
  event Burn(uint256 value);

  

  
  modifier onlyOwner() {
    require(owners[msg.sender] == true);
    _;
  }

  

  
  function RxEALTokenContract() {
    owners[msg.sender] = true;
    totalSupply = INITIAL_SUPPLY;
    balances[vault] = totalSupply;
  }

  
  function grantOwnership(address _owner) onlyOwner public {
    require(_owner != address(0));
    owners[_owner] = true;
    OwnershipGranted(msg.sender, _owner);
  }

  
  function revokeOwnership(address _owner) onlyOwner public {
    require(_owner != msg.sender);
    owners[_owner] = false;
    OwnershipRevoked(msg.sender, _owner);
  }

  
  function transferSalesAgentPermissions(address _salesAgent) onlyOwner public {
    SalesAgentPermissionsTransferred(salesAgent, _salesAgent);
    salesAgent = _salesAgent;
  }

  
  function removeSalesAgent() onlyOwner public {
    SalesAgentRemoved(salesAgent);
    salesAgent = address(0);
  }

  
  function transferTokensFromVault(address _from, address _to, uint256 _amount) public {
    require(salesAgent == msg.sender);
    balances[vault] = balances[vault].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(_from, _to, _amount);
  }

  
  function burn(uint256 _value) onlyOwner public {
    require(_value > 0);
    balances[vault] = balances[vault].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_value);
  }

}






