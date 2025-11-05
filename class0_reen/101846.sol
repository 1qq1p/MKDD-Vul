pragma solidity 0.4.15;




contract SSPRegistry is SSPTypeAware{
    
    function register(address key, SSPType sspType, uint16 publisherFee, address recordOwner);

    
    function updatePublisherFee(address key, uint16 newFee, address sender);

    function applyKarmaDiff(address key, uint256[2] diff);

    
    function unregister(address key, address sender);

    
    function transfer(address key, address newOwner, address sender);

    function getOwner(address key) constant returns(address);

    
    function isRegistered(address key) constant returns(bool);

    function getSSP(address key) constant returns(address sspAddress, SSPType sspType, uint16 publisherFee, uint256[2] karma, address recordOwner);

    function getAllSSP() constant returns(address[] addresses, SSPType[] sspTypes, uint16[] publisherFees, uint256[2][] karmas, address[] recordOwners);

    function kill();
}
