pragma solidity ^0.4.25;





library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); 
    uint256 c = _a / _b;
    

    return c;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Spoke is DSAuth {
    Hub public hub;
    Hub.Routes public routes;
    bool public initialized;

    modifier onlyInitialized() {
        require(initialized, "Component not yet initialized");
        _;
    }

    modifier notShutDown() {
        require(!hub.isShutDown(), "Hub is shut down");
        _;
    }

    constructor(address _hub) {
        hub = Hub(_hub);
        setAuthority(hub);
        setOwner(hub); 
    }

    function initialize(address[12] _spokes) external auth {
        require(msg.sender == address(hub));
        require(!initialized, "Already initialized");
        routes = Hub.Routes(
            _spokes[0],
            _spokes[1],
            _spokes[2],
            _spokes[3],
            _spokes[4],
            _spokes[5],
            _spokes[6],
            _spokes[7],
            _spokes[8],
            _spokes[9],
            _spokes[10],
            _spokes[11]
        );
        initialized = true;
        setOwner(address(0));
    }

    function engine() public view returns (address) { return routes.engine; }
    function mlnToken() public view returns (address) { return routes.mlnToken; }
    function priceSource() public view returns (address) { return routes.priceSource; }
    function version() public view returns (address) { return routes.version; }
    function registry() public view returns (address) { return routes.registry; }
}



