pragma solidity 0.5.9; 































interface IHomeWork {
  
  event NewResident(
    address indexed homeAddress,
    bytes32 key,
    bytes32 runtimeCodeHash
  );

  
  event NewRuntimeStorageContract(
    address runtimeStorageContract,
    bytes32 runtimeCodeHash
  );

  
  event NewController(bytes32 indexed key, address newController);

  
  event NewHighScore(bytes32 key, address submitter, uint256 score);

  
  struct HomeAddress {
    bool exists;
    address controller;
    uint88 deploys;
  }

  
  struct KeyInformation {
    bytes32 key;
    bytes32 salt;
    address submitter;
  }

  



























  function deploy(bytes32 key, bytes calldata initializationCode)
    external
    payable
    returns (address homeAddress, bytes32 runtimeCodeHash);

  


















  function lock(bytes32 key, address owner) external;

  













  function redeem(uint256 tokenId, address controller) external;

  














  function assignController(bytes32 key, address controller) external;

  









  function relinquishControl(bytes32 key) external;

  

































  function redeemAndDeploy(
    uint256 tokenId,
    address controller,
    bytes calldata initializationCode
  )
    external
    payable
    returns (address homeAddress, bytes32 runtimeCodeHash);

  














  function deriveKey(bytes32 salt) external returns (bytes32 key);

  


















  function deriveKeyAndLock(bytes32 salt, address owner)
    external
    returns (bytes32 key);

  














  function deriveKeyAndAssignController(bytes32 salt, address controller)
    external
    returns (bytes32 key);

  









  function deriveKeyAndRelinquishControl(bytes32 salt)
    external
    returns (bytes32 key);

  









  function setReverseLookup(bytes32 key) external;

  









  function setDerivedReverseLookup(bytes32 salt, address submitter) external;

  














  function deployRuntimeStorageContract(bytes calldata codePayload)
    external
    returns (address runtimeStorageContract);

  




























  function deployViaExistingRuntimeStorageContract(
    bytes32 key,
    address initializationRuntimeStorageContract
  )
    external
    payable
    returns (address homeAddress, bytes32 runtimeCodeHash);

  


































  function redeemAndDeployViaExistingRuntimeStorageContract(
    uint256 tokenId,
    address controller,
    address initializationRuntimeStorageContract
  )
    external
    payable
    returns (address homeAddress, bytes32 runtimeCodeHash);

  





























  function deriveKeyAndDeploy(bytes32 salt, bytes calldata initializationCode)
    external
    payable
    returns (address homeAddress, bytes32 key, bytes32 runtimeCodeHash);

  






























  function deriveKeyAndDeployViaExistingRuntimeStorageContract(
    bytes32 salt,
    address initializationRuntimeStorageContract
  )
    external
    payable
    returns (address homeAddress, bytes32 key, bytes32 runtimeCodeHash);

  












  function batchLock(address owner, bytes32[] calldata keys) external;

  











  function deriveKeysAndBatchLock(address owner, bytes32[] calldata salts)
    external;

  










  function batchLock_63efZf() external;

  













  function claimHighScore(bytes32 key) external;

  













  function recover(IERC20 token, address payable recipient) external;

  












  function isDeployable(bytes32 key)
    external
    
    returns (bool deployable);

  






  function getHighScore()
    external
    view
    returns (address holder, uint256 score, bytes32 key);

  













  function getHomeAddressInformation(bytes32 key)
    external
    view
    returns (
      address homeAddress,
      address controller,
      uint256 deploys,
      bytes32 currentRuntimeCodeHash
    );

  







  function hasNeverBeenDeployed(bytes32 key)
    external
    view
    returns (bool neverBeenDeployed);

  












  function reverseLookup(address homeAddress)
    external
    view
    returns (bytes32 key, bytes32 salt, address submitter);

  







  function getDerivedKey(bytes32 salt, address submitter)
    external
    pure
    returns (bytes32 key);

  





  function getHomeAddress(bytes32 key)
    external
    pure
    returns (address homeAddress);

  







  function getMetamorphicDelegatorInitializationCode()
    external
    pure
    returns (bytes32 metamorphicDelegatorInitializationCode);

  







  function getMetamorphicDelegatorInitializationCodeHash()
    external
    pure
    returns (bytes32 metamorphicDelegatorInitializationCodeHash);

  




  function getArbitraryRuntimeCodePrelude()
    external
    pure
    returns (bytes11 prelude);
}






interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}






interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}






interface IERC721Metadata {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}







interface IERC721Receiver {
    













    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
      external
      returns (bytes4);
}






interface IERC1412 {
  
  
  
  
  
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data) external;
  
  
  
  
  
  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds) external; 
}






interface IERC165 {
    





    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}






interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}















library SafeMath {
    








    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    








    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    








    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    










    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    










    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}





library Address {
    






    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}













library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}








contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    
    mapping (uint256 => address) private _tokenOwner;

    
    mapping (uint256 => address) private _tokenApprovals;

    
    mapping (address => Counters.Counter) private _ownedTokensCount;

    
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    












    constructor () public {
        
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    




    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    




    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    







    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    





    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    





    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    





    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    







    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    










    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    











    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    




    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    






    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    





    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    






    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    




    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    






    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    








    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    



    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}





