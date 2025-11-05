

pragma solidity >=0.4.24;

interface ENS {

    
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    
    event Transfer(bytes32 indexed node, address owner);

    
    event NewResolver(bytes32 indexed node, address resolver);

    
    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
    function ttl(bytes32 node) external view returns (uint64);

}



pragma solidity >=0.4.24;

interface Deed {

    function setOwner(address payable newOwner) external;
    function setRegistrar(address newRegistrar) external;
    function setBalance(uint newValue, bool throwOnFailure) external;
    function closeDeed(uint refundRatio) external;
    function destroyDeed() external;

    function owner() external view returns (address);
    function previousOwner() external view returns (address);
    function value() external view returns (uint);
    function creationDate() external view returns (uint);

}



pragma solidity >=0.4.24;


interface Registrar {

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    event AuctionStarted(bytes32 indexed hash, uint registrationDate);
    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);
    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);
    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);
    event HashReleased(bytes32 indexed hash, uint value);
    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);

    function startAuction(bytes32 _hash) external;
    function startAuctions(bytes32[] calldata _hashes) external;
    function newBid(bytes32 sealedBid) external payable;
    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable;
    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external;
    function cancelBid(address bidder, bytes32 seal) external;
    function finalizeAuction(bytes32 _hash) external;
    function transfer(bytes32 _hash, address payable newOwner) external;
    function releaseDeed(bytes32 _hash) external;
    function invalidateName(string calldata unhashedName) external;
    function eraseNode(bytes32[] calldata labels) external;
    function transferRegistrars(bytes32 _hash) external;
    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external;
    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint);
}



pragma solidity ^0.5.0;






contract BaseRegistrar is ERC721, Ownable {
    uint constant public GRACE_PERIOD = 90 days;

    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameMigrated(uint256 indexed id, address indexed owner, uint expires);
    event NameRegistered(uint256 indexed id, address indexed owner, uint expires);
    event NameRenewed(uint256 indexed id, uint expires);

    
    uint public transferPeriodEnds;

    
    ENS public ens;

    
    bytes32 public baseNode;

    
    HashRegistrar public previousRegistrar;

    
    mapping(address=>bool) public controllers;

    
    function addController(address controller) external;

    
    function removeController(address controller) external;

    
    function setResolver(address resolver) external;

    
    function nameExpires(uint256 id) external view returns(uint);

    
    function available(uint256 id) public view returns(bool);

    


    function register(uint256 id, address owner, uint duration) external returns(uint);

    function renew(uint256 id, uint duration) external returns(uint);

    


    function reclaim(uint256 id, address owner) external;

    



    function acceptRegistrarTransfer(bytes32 label, Deed deed, uint) external;
}



pragma solidity ^0.5.0;




