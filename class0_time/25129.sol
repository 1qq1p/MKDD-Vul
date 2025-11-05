pragma solidity ^0.4.24;



contract TokenDotFactory is Ownable {

    CurrentCostInterface currentCost;
    FactoryTokenInterface public reserveToken;
    ZapCoordinatorInterface public coord;
    TokenFactoryInterface public tokenFactory;
    BondageInterface bondage;

    mapping(bytes32 => address) public curves;

    event DotTokenCreated(address tokenAddress);

    constructor(
        address coordinator, 
        address factory,
        uint256 providerPubKey,
        bytes32 providerTitle 
    ){
        coord = ZapCoordinatorInterface(coordinator); 
        reserveToken = FactoryTokenInterface(coord.getContract("ZAP_TOKEN"));
        
        reserveToken.approve(coord.getContract("BONDAGE"), ~uint256(0));
        tokenFactory = TokenFactoryInterface(factory);

        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        registry.initiateProvider(providerPubKey, providerTitle);
    }

    function initializeCurve(
        bytes32 specifier, 
        bytes32 symbol, 
        int256[] curve
    ) public returns(address) {
        
        require(curves[specifier] == 0, "Curve specifier already exists");
        
        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        require(registry.isProviderInitiated(address(this)), "Provider not intiialized");

        registry.initiateProviderCurve(specifier, curve, address(this));
        curves[specifier] = newToken(bytes32ToString(specifier), bytes32ToString(symbol));
        
        registry.setProviderParameter(specifier, toBytes(curves[specifier]));
        
        DotTokenCreated(curves[specifier]);
        return curves[specifier];
    }


    event Bonded(bytes32 indexed specifier, uint256 indexed numDots, address indexed sender); 

    
    function bond(bytes32 specifier, uint numDots) public  {

        bondage = BondageInterface(coord.getContract("BONDAGE"));
        uint256 issued = bondage.getDotsIssued(address(this), specifier);

        CurrentCostInterface cost = CurrentCostInterface(coord.getContract("CURRENT_COST"));
        uint256 numReserve = cost._costOfNDots(address(this), specifier, issued + 1, numDots - 1);

        require(
            reserveToken.transferFrom(msg.sender, address(this), numReserve),
            "insufficient accepted token numDots approved for transfer"
        );

        reserveToken.approve(address(bondage), numReserve);
        bondage.bond(address(this), specifier, numDots);
        FactoryTokenInterface(curves[specifier]).mint(msg.sender, numDots);
        Bonded(specifier, numDots, msg.sender);

    }

    event Unbonded(bytes32 indexed specifier, uint256 indexed numDots, address indexed sender); 

    
    function unbond(bytes32 specifier, uint numDots) public {

        bondage = BondageInterface(coord.getContract("BONDAGE"));
        uint issued = bondage.getDotsIssued(address(this), specifier);

        currentCost = CurrentCostInterface(coord.getContract("CURRENT_COST"));
        uint reserveCost = currentCost._costOfNDots(address(this), specifier, issued + 1 - numDots, numDots - 1);

        
        bondage.unbond(address(this), specifier, numDots);
        
        FactoryTokenInterface curveToken = FactoryTokenInterface(curves[specifier]);
        curveToken.burnFrom(msg.sender, numDots);

        require(reserveToken.transfer(msg.sender, reserveCost), "Error: Transfer failed");
        Unbonded(specifier, numDots, msg.sender);

    }

    function newToken(
        string name,
        string symbol
    ) 
        public
        returns (address tokenAddress) 
    {
        FactoryTokenInterface token = tokenFactory.create(name, symbol);
        tokenAddress = address(token);
        return tokenAddress;
    }

    function getTokenAddress(bytes32 specifier) public view returns(address) {
        RegistryInterface registry = RegistryInterface(coord.getContract("REGISTRY")); 
        return bytesToAddr(registry.getProviderParameter(address(this), specifier));
    }

    
    function toBytes(address x) public pure returns (bytes b) {
        b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    }

    
    function bytes32ToString(bytes32 x) public pure returns (string) {
        bytes memory bytesString = new bytes(32);

        bytesString = abi.encodePacked(x);

        return string(bytesString);
    }

    
    function bytesToAddr (bytes b) public pure returns (address) {
        uint result = 0;
        for (uint i = b.length-1; i+1 > 0; i--) {
            uint c = uint(b[i]);
            uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
            result += to_inc;
        }
        return address(result);
    }


}