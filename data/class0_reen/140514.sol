
pragma solidity ^0.5.2;





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







contract PrzToken is ERC20Detailed, ERC20Mintable, ERC20Destroyable, ERC20Pausable, Ownable {

    
    address private _entryCreditContract;

    
    address private _balanceSheetContract;

    
    uint256 private _bmeClaimBatchSize;
    uint256 private _bmeMintBatchSize;

    
    
    
    bool private _isInBmePhase;

    modifier whenNotInBME() {
        require(!_isInBmePhase, "Function may no longer be called once BME starts");
        _;
    }

    modifier whenInBME() {
        require(_isInBmePhase, "Function may only be called once BME starts");
        _;
    }

    event EntryCreditContractChanged(
        address indexed previousEntryCreditContract,
        address indexed newEntryCreditContract
    );

    event BalanceSheetContractChanged(
        address indexed previousBalanceSheetContract,
        address indexed newBalanceSheetContract
    );

    event BmeMintBatchSizeChanged(
        uint256 indexed previousSize,
        uint256 indexed newSize
    );

    event BmeClaimBatchSizeChanged(
        uint256 indexed previousSize,
        uint256 indexed newSize
    );

    event PhaseChangedToBME(address account);


    


    constructor (string memory name, string memory symbol, uint8 decimals)
        ERC20Detailed(name, symbol, decimals)
        ERC20Mintable()
        ERC20Destroyable()
        ERC20Pausable()
        Ownable()
        public
    {
        _isInBmePhase = false;
        pause();
        setEntryCreditContract(address(0));
        setBalanceSheetContract(address(0));
        setBmeMintBatchSize(200);
        setBmeClaimBatchSize(200);
    }

    
    function entryCreditContract() public view returns (address) {
        return _entryCreditContract;
    }

    
    function setEntryCreditContract(address contractAddress) public onlyOwner {
        emit EntryCreditContractChanged(_entryCreditContract, contractAddress);
        _entryCreditContract = contractAddress;
    }

    
    function balanceSheetContract() public view returns (address) {
        return _balanceSheetContract;
    }

    
    function setBalanceSheetContract(address contractAddress) public onlyOwner {
        emit BalanceSheetContractChanged(_balanceSheetContract, contractAddress);
        _balanceSheetContract = contractAddress;
    }

    
    function bmeMintBatchSize() public view returns (uint256) {
        return _bmeMintBatchSize;
    }

    
    function setBmeMintBatchSize(uint256 batchSize) public onlyMinter {
        emit BmeMintBatchSizeChanged(_bmeMintBatchSize, batchSize);
        _bmeMintBatchSize = batchSize;
    }

    
    function bmeClaimBatchSize() public view returns (uint256) {
        return _bmeClaimBatchSize;
    }

    
    function setBmeClaimBatchSize(uint256 batchSize) public onlyMinter {
        emit BmeClaimBatchSizeChanged(_bmeClaimBatchSize, batchSize);
        _bmeClaimBatchSize = batchSize;
    }

    
    
    
    function _transfer(address from, address to, uint256 value) internal {

        if (to == _entryCreditContract) {

            _burn(from, value);
            IEntryCreditContract entryCreditContractInstance = IEntryCreditContract(to);
            require(entryCreditContractInstance.mint(from, value), "Failed to mint entry credits");

            IBalanceSheetContract balanceSheetContractInstance = IBalanceSheetContract(_balanceSheetContract);
            require(balanceSheetContractInstance.setPeerzTokenSupply(totalSupply()), "Failed to update token supply");

        } else {

            super._transfer(from, to, value);
        }
    }

    
    function destroy(address from, uint256 value)
        public whenPaused whenNotInBME
        returns (bool)
    {
        return super.destroy(from, value);
    }

    
    function batchDestroy(address[] calldata from, uint256[] calldata values)
        external onlyDestroyer whenPaused whenNotInBME
        returns (bool)
    {
        uint fromLength = from.length;

        require(fromLength == values.length, "Input arrays must have the same length");

        for (uint256 i = 0; i < fromLength; i++) {
            _burn(from[i], values[i]);
        }

        return true;
    }

    
    function mint(address to, uint256 value)
        public whenPaused whenNotInBME
        returns (bool)
    {
        return super.mint(to, value);
    }

    
    function batchMint(address[] calldata to, uint256[] calldata values)
        external onlyMinter whenPaused whenNotInBME
        returns (bool)
    {
        _batchMint(to, values);

        return true;
    }

    
    
    function bmeMint()
        public onlyMinter whenInBME whenNotPaused
    {
        IBalanceSheetContract balanceSheetContractInstance = IBalanceSheetContract(_balanceSheetContract);
        (address[] memory receivers, uint256[] memory amounts) = balanceSheetContractInstance.popMintingInformation(_bmeMintBatchSize);

        _batchMint(receivers, amounts);

        require(balanceSheetContractInstance.setPeerzTokenSupply(totalSupply()), "Failed to update token supply");
    }

    
    
    function _claimFor(address[] memory claimers)
        private
    {
        IBalanceSheetContract balanceSheetContractInstance = IBalanceSheetContract(_balanceSheetContract);
        uint256[] memory amounts = balanceSheetContractInstance.popClaimingInformation(claimers);

        _batchMint(claimers, amounts);

        require(balanceSheetContractInstance.setPeerzTokenSupply(totalSupply()), "Failed to update token supply");
    }

    function _batchMint(address[] memory to, uint256[] memory values)
        private
    {

        
        uint toLength = to.length;

        require(toLength == values.length, "Input arrays must have the same length");

        for (uint256 i = 0; i < toLength; i++) {
            _mint(to[i], values[i]);
        }
    }

    
    function claim()
        public whenInBME whenNotPaused
    {
        address[] memory claimers = new address[](1);
        claimers[0] = msg.sender;
        _claimFor(claimers);
    }

    
    function claimFor(address[] calldata claimers)
        external whenInBME whenNotPaused
    {
        require(claimers.length <= _bmeClaimBatchSize, "Input array must be shorter than bme claim batch size.");
        _claimFor(claimers);
    }

    
    function changePhaseToBME()
        public onlyOwner whenNotPaused whenNotInBME
    {
        _isInBmePhase = true;
        emit PhaseChangedToBME(msg.sender);
    }
}

interface IEntryCreditContract {

    function mint(address receiver, uint256 amount) external returns (bool);
}



















interface IBalanceSheetContract {

    function setPeerzTokenSupply(uint256 przTotalSupply) external returns (bool);

    
    function popMintingInformation(uint256 bmeMintBatchSize) external returns (address[] memory, uint256[] memory);

    
    function popClaimingInformation(address[] calldata claimers) external returns (uint256[] memory);
}