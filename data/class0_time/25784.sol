pragma solidity ^0.4.15;






contract Ownable {
  address public owner;


  



  function Ownable() {
    owner = msg.sender;
  }


  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  



  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

interface AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);

    
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    
    event Transfer(bytes32 indexed node, address owner);

    
    event NewResolver(bytes32 indexed node, address resolver);

    
    event NewTTL(bytes32 indexed node, uint64 ttl);
}

interface InterCrypto_Interface {
    
    event ConversionStarted(uint indexed conversionID);
    event ConversionSentToShapeShift(uint indexed conversionID, address indexed returnAddress, address indexed depositAddress, uint amount);
    event ConversionAborted(uint indexed conversionID, string reason);
    event Recovered(address indexed recoveredTo, uint amount);

    
    function getInterCryptoPrice() constant public returns (uint);
    function convert1(string _coinSymbol, string _toAddress) external payable returns (uint conversionID);
    function convert2(string _coinSymbol, string _toAddress, address _returnAddress) external payable returns(uint conversionID);
    function recover() external;
    function recoverable(address myAddress) constant public returns (uint);
    function cancelConversion(uint conversionID) external;
}

interface AbstractPublicResolver {
    function PublicResolver(address ensAddr);
    function supportsInterface(bytes4 interfaceID) constant returns (bool);
    function addr(bytes32 node) constant returns (address ret);
    function setAddr(bytes32 node, address addr);
    function hash(bytes32 node) constant returns (bytes32 ret);
    function setHash(bytes32 node, bytes32 hash);
}
