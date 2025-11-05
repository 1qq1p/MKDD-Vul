pragma solidity ^0.4.24;





interface ERC223I {

  function balanceOf(address _owner) external view returns (uint balance);
  
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function decimals() external view returns (uint8 _decimals);
  function totalSupply() external view returns (uint256 supply);

  function transfer(address to, uint value) external returns (bool ok);
  function transfer(address to, uint value, bytes data) external returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) external returns (bool ok);

  function releaseTokenTransfer() external;
  
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);  
}





contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;  

  event UpdatedAgent(address _agent, bool _status);

  constructor() public {
    defAgent = msg.sender;
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;

    emit UpdatedAgent(_agent, _status);
  }  
}





