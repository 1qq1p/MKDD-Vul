pragma solidity 0.4.24;

interface AbstractENS {
    function owner(bytes32 _node) public constant returns (address);
    function resolver(bytes32 _node) public constant returns (address);
    function ttl(bytes32 _node) public constant returns (uint64);
    function setOwner(bytes32 _node, address _owner) public;
    function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner) public;
    function setResolver(bytes32 _node, address _resolver) public;
    function setTTL(bytes32 _node, uint64 _ttl) public;

    
    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    
    event Transfer(bytes32 indexed _node, address _owner);

    
    event NewResolver(bytes32 indexed _node, address _resolver);

    
    event NewTTL(bytes32 indexed _node, uint64 _ttl);
}





contract AppProxyUpgradeable is AppProxyBase {
    





    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public 
    {

    }

    


    function implementation() public view returns (address) {
        return getAppBase(appId());
    }

    


    function proxyType() public pure returns (uint256 proxyTypeId) {
        return UPGRADEABLE;
    }
}
