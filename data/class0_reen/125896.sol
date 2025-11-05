pragma solidity ^0.4.21;




























contract SuNFT is ERC165, ERC721, ERC721Metadata, ERC721Enumerable, PublishInterfaces {
    
    mapping (uint256 => address) internal tokenApprovals;

    
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    
    
    modifier onlyOwnerOf(uint256 _tokenId) {
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        
        require(msg.sender == owner);
        _;
    }
    
    modifier mustBeOwnedByThisContract(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= TOTAL_SUPPLY);
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        require(owner == address(0) || owner == address(this));
        _;
    }
    
    modifier canOperate(uint256 _tokenId) {
        
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        require(msg.sender == owner || operatorApprovals[owner][msg.sender]);
        _;
    }
    
    modifier canTransfer(uint256 _tokenId) {
        
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        require(msg.sender == owner || 
          msg.sender == tokenApprovals[_tokenId] || 
          operatorApprovals[msg.sender][msg.sender]);
        _;
    }
    
    modifier mustBeValidToken(uint256 _tokenId) {
        require(_tokenId >= 1 && _tokenId <= TOTAL_SUPPLY);
        _;
    }
    
    
    
    
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    
    
    
    
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    
    
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    
    
    
    
    
    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0));
        return _tokensOfOwnerWithSubstitutions[_owner].length;
    }

    
    
    
    
    
    function ownerOf(uint256 _tokenId) 
        external
        view
        mustBeValidToken(_tokenId)
        returns (address _owner)
    {
        _owner = _tokenOwnerWithSubstitutions[_tokenId];
        
        if (_owner == address(0)) {
            _owner = address(this);
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable
    {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }
	
    
    
    
    
    
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable
    {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    
    
    
    
    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _tokenId)
        external
        payable
        mustBeValidToken(_tokenId)
        canTransfer(_tokenId)
    {
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        
        if (owner == address(0)) {
            owner = address(this);
        }
        require(owner == _from);
        require(_to != address(0));
        _transfer(_tokenId, _to);
    }

    
    
    
    
    
    
    function approve(address _approved, uint256 _tokenId)
        external
        payable
        
        canOperate(_tokenId)
    {
        address _owner = _tokenOwnerWithSubstitutions[_tokenId];
        
        if (_owner == address(0)) {
            _owner = address(this);
        }
        tokenApprovals[_tokenId] = _approved;
        emit Approval(_owner, _approved, _tokenId);
    }

    
    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) external {
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    
    
    
    
    function getApproved(uint256 _tokenId)
        external
        view
        mustBeValidToken(_tokenId)
        returns (address)
    {
        return tokenApprovals[_tokenId];        
    }

    
    
    
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }
    
    

    
    function name() external pure returns (string) {
        return "Su Squares";
    }

    
    function symbol() external pure returns (string) {
        return "SU";
    }

    
    
    
    
    function tokenURI(uint256 _tokenId) 
        external
        view
        mustBeValidToken(_tokenId)
        returns (string _tokenURI)
    {
        _tokenURI = "https://tenthousandsu.com/erc721/00000.json";
        bytes memory _tokenURIBytes = bytes(_tokenURI);
        _tokenURIBytes[33] = byte(48+(_tokenId / 10000) % 10);
        _tokenURIBytes[34] = byte(48+(_tokenId / 1000) % 10);
        _tokenURIBytes[35] = byte(48+(_tokenId / 100) % 10);
        _tokenURIBytes[36] = byte(48+(_tokenId / 10) % 10);
        _tokenURIBytes[37] = byte(48+(_tokenId / 1) % 10);
        
    }

    

    
    
    
    function totalSupply() external view returns (uint256) {
        return TOTAL_SUPPLY;
    }

    
    
    
    
    
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < TOTAL_SUPPLY);
        return _index + 1;
    }

    
    
    
    
    
    
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
        require(_owner != address(0));
        require(_index < _tokensOfOwnerWithSubstitutions[_owner].length);
        _tokenId = _tokensOfOwnerWithSubstitutions[_owner][_index];
        
        if (_owner == address(this)) {
            if (_tokenId == 0) {
                _tokenId = _index + 1;
            }
        }
    }

    

    
    function _transfer(uint256 _tokenId, address _to) internal {
        
        
        
        require(_to != address(0));

        
        address fromWithSubstitution = _tokenOwnerWithSubstitutions[_tokenId];
        address from = fromWithSubstitution;
        if (fromWithSubstitution == address(0)) {
            from = address(this);
        }

        
        
        uint256 indexToDeleteWithSubstitution = _ownedTokensIndexWithSubstitutions[_tokenId];
        uint256 indexToDelete;
        if (indexToDeleteWithSubstitution == 0) {
            indexToDelete = _tokenId - 1;
        } else {
            indexToDelete = indexToDeleteWithSubstitution - 1;
        }
        if (indexToDelete != _tokensOfOwnerWithSubstitutions[from].length - 1) {
            uint256 lastNftWithSubstitution = _tokensOfOwnerWithSubstitutions[from][_tokensOfOwnerWithSubstitutions[from].length - 1];
            uint256 lastNft = lastNftWithSubstitution;
            if (lastNftWithSubstitution == 0) {
                
                lastNft = _tokensOfOwnerWithSubstitutions[from].length;
            }
            _tokensOfOwnerWithSubstitutions[from][indexToDelete] = lastNft;
            _ownedTokensIndexWithSubstitutions[lastNft] = indexToDelete + 1;
        }
        delete _tokensOfOwnerWithSubstitutions[from][_tokensOfOwnerWithSubstitutions[from].length - 1]; 
        _tokensOfOwnerWithSubstitutions[from].length--;
        

        
        _tokensOfOwnerWithSubstitutions[_to].push(_tokenId);
        _ownedTokensIndexWithSubstitutions[_tokenId] = (_tokensOfOwnerWithSubstitutions[_to].length - 1) + 1;

        
        _tokenOwnerWithSubstitutions[_tokenId] = _to;
        tokenApprovals[_tokenId] = address(0);
        emit Transfer(from, _to, _tokenId);
    }
    
    

    uint256 private constant TOTAL_SUPPLY = 10000; 

    bytes4 private constant ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
    
    
    
    
    
    
    mapping (uint256 => address) private _tokenOwnerWithSubstitutions;

    
    
    
    
    
    
    mapping (address => uint256[]) private _tokensOfOwnerWithSubstitutions;
    
    
    
    
    
    
    
    mapping (uint256 => uint256) private _ownedTokensIndexWithSubstitutions;

    
    
    
    
    
    
    function SuNFT() internal {
        
        supportedInterfaces[0x6466353c] = true; 
        supportedInterfaces[0x5b5e139f] = true; 
        supportedInterfaces[0x780e9d63] = true; 
        
        
        
        
        
        
        

        
        
        _tokensOfOwnerWithSubstitutions[address(this)].length = TOTAL_SUPPLY;
        
        
        
        
        
        
    }
    
    
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data)
        private
        mustBeValidToken(_tokenId)
        canTransfer(_tokenId)
    {
        address owner = _tokenOwnerWithSubstitutions[_tokenId];
        
        if (owner == address(0)) {
            owner = address(this);
        }
        require(owner == _from);
        require(_to != address(0));
        _transfer(_tokenId, _to);
        
        
        uint256 codeSize;
        assembly { codeSize := extcodesize(_to) }
        if (codeSize == 0) {
            return;
        }
        bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
        require(retval == ERC721_RECEIVED);
    }    
}





