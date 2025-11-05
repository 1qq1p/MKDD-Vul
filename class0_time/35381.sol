pragma solidity ^0.5.0;

pragma solidity ^0.5.0;




interface ERC721Proxy  {

    
    
    
    
    
    
    function supportsInterface(bytes4 interfaceID) external view returns (bool);

    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    
    
    
    
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    
    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    
    
    
    function balanceOf(address _owner) external view returns (uint256);

    
    
    
    
    
    function ownerOf(uint256 _tokenId) external view returns (address);

    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;

    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    
    
    
    
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    
    
    
    
    
    
    function approve(address _approved, uint256 _tokenId) external;

    
    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external;

    
    
    
    
    function getApproved(uint256 _tokenId) external view returns (address);

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    
    function name() external view returns (string memory _name);

    
    function symbol() external view returns (string memory _symbol);


    
    
    
    
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    
    
    
    function totalSupply() external view returns (uint256);

    
    
    
    
    
    function tokenByIndex(uint256 _index) external view returns (uint256);

    
    
    
    
    
    
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

    
    
    
    
    function transfer(address _to, uint256 _tokenId) external;

    function onTransfer(address _from, address _to, uint256 _nftIndex) external;
}

pragma solidity ^0.5.0;



interface UriProviderInterface
{
    
    
    
    
    function tokenURI(uint256 _tokenId) external view returns (string memory infoUrl);
}

pragma solidity ^0.5.0;

interface BlockchainCutiesERC1155Interface
{
    function mintNonFungibleSingleShort(uint128 _type, address _to) external;
    function mintNonFungibleSingle(uint256 _type, address _to) external;
    function mintNonFungibleShort(uint128 _type, address[] calldata _to) external;
    function mintNonFungible(uint256 _type, address[] calldata _to) external;
    function mintFungibleSingle(uint256 _id, address _to, uint256 _quantity) external;
    function mintFungible(uint256 _id, address[] calldata _to, uint256[] calldata _quantities) external;
    function isNonFungible(uint256 _id) external pure returns(bool);
    function ownerOf(uint256 _id) external view returns (address);
    function totalSupplyNonFungible(uint256 _type) view external returns (uint256);
    function totalSupplyNonFungibleShort(uint128 _type) view external returns (uint256);

    





    function uri(uint256 _id) external view returns (string memory);
    function proxyTransfer721(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;
    function proxyTransfer20(address _from, address _to, uint256 _tokenId, uint256 _value) external;
    





    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    













    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
}

pragma solidity ^0.5.0;

contract Operators
{
    mapping (address=>bool) ownerAddress;
    mapping (address=>bool) operatorAddress;

    constructor() public
    {
        ownerAddress[msg.sender] = true;
    }

    modifier onlyOwner()
    {
        require(ownerAddress[msg.sender]);
        _;
    }

    function isOwner(address _addr) public view returns (bool) {
        return ownerAddress[_addr];
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));

        ownerAddress[_newOwner] = true;
    }

    function removeOwner(address _oldOwner) external onlyOwner {
        delete(ownerAddress[_oldOwner]);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || ownerAddress[_addr];
    }

    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0));

        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }
}

