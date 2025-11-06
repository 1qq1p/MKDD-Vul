

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



pragma solidity ^0.5.0;






contract EthRegistrarSubdomainRegistrar is AbstractSubdomainRegistrar {

    struct Domain {
        string name;
        address payable owner;
        uint price;
        uint referralFeePPM;
    }

    mapping (bytes32 => Domain) domains;

    constructor(ENS ens) AbstractSubdomainRegistrar(ens) public { }

    








    function owner(bytes32 label) public view returns (address) {
        if (domains[label].owner != address(0x0)) {
            return domains[label].owner;
        }

        return BaseRegistrar(registrar).ownerOf(uint256(label));
    }

    





    function transfer(string memory name, address payable newOwner) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        emit OwnerChanged(label, domains[label].owner, newOwner);
        domains[label].owner = newOwner;
    }

    









    function configureDomainFor(string memory name, uint price, uint referralFeePPM, address payable _owner, address _transfer) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        Domain storage domain = domains[label];

        if (BaseRegistrar(registrar).ownerOf(uint256(label)) != address(this)) {
            BaseRegistrar(registrar).transferFrom(msg.sender, address(this), uint256(label));
            BaseRegistrar(registrar).reclaim(uint256(label), address(this));
        }

        if (domain.owner != _owner) {
            domain.owner = _owner;
        }

        if (keccak256(bytes(domain.name)) != label) {
            
            domain.name = name;
        }

        domain.price = price;
        domain.referralFeePPM = referralFeePPM;

        emit DomainConfigured(label);
    }

    




    function unlistDomain(string memory name) public owner_only(keccak256(bytes(name))) {
        bytes32 label = keccak256(bytes(name));
        Domain storage domain = domains[label];
        emit DomainUnlisted(label);

        domain.name = '';
        domain.price = 0;
        domain.referralFeePPM = 0;
    }

    









    function query(bytes32 label, string calldata subdomain) external view returns (string memory domain, uint price, uint rent, uint referralFeePPM) {
        bytes32 node = keccak256(abi.encodePacked(TLD_NODE, label));
        bytes32 subnode = keccak256(abi.encodePacked(node, keccak256(bytes(subdomain))));

        if (ens.owner(subnode) != address(0x0)) {
            return ('', 0, 0, 0);
        }

        Domain storage data = domains[label];
        return (data.name, data.price, 0, data.referralFeePPM);
    }

    






    function register(bytes32 label, string calldata subdomain, address _subdomainOwner, address payable referrer, address resolver) external not_stopped payable {
        address subdomainOwner = _subdomainOwner;
        bytes32 domainNode = keccak256(abi.encodePacked(TLD_NODE, label));
        bytes32 subdomainLabel = keccak256(bytes(subdomain));

        
        require(ens.owner(keccak256(abi.encodePacked(domainNode, subdomainLabel))) == address(0));

        Domain storage domain = domains[label];

        
        require(keccak256(bytes(domain.name)) == label);

        
        require(msg.value >= domain.price);

        
        if (msg.value > domain.price) {
            msg.sender.transfer(msg.value - domain.price);
        }

        
        uint256 total = domain.price;
        if (domain.referralFeePPM > 0 && referrer != address(0x0) && referrer != domain.owner) {
            uint256 referralFee = (domain.price * domain.referralFeePPM) / 1000000;
            referrer.transfer(referralFee);
            total -= referralFee;
        }

        
        if (total > 0) {
            domain.owner.transfer(total);
        }

        
        if (subdomainOwner == address(0x0)) {
            subdomainOwner = msg.sender;
        }
        doRegistration(domainNode, subdomainLabel, subdomainOwner, Resolver(resolver));

        emit NewRegistration(label, subdomain, subdomainOwner, referrer, domain.price);
    }

    function rentDue(bytes32 label, string calldata subdomain) external view returns (uint timestamp) {
        return 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

    



    function migrate(string memory name) public owner_only(keccak256(bytes(name))) {
        require(stopped);
        require(migration != address(0x0));

        bytes32 label = keccak256(bytes(name));
        Domain storage domain = domains[label];

        BaseRegistrar(registrar).approve(migration, uint256(label));

        EthRegistrarSubdomainRegistrar(migration).configureDomainFor(
            domain.name,
            domain.price,
            domain.referralFeePPM,
            domain.owner,
            address(0x0)
        );

        delete domains[label];

        emit DomainTransferred(label, name);
    }

    function payRent(bytes32 label, string calldata subdomain) external payable {
        revert();
    }
}