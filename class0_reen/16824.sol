pragma solidity ^0.4.24;




contract SecurityToken is ISecurityToken, ReentrancyGuard, RegistryUpdater {
    using SafeMath for uint256;

    bytes32 public constant securityTokenVersion = "0.0.1";

    
    ITokenBurner public tokenBurner;

    
    bool public freeze = false;

    struct ModuleData {
        bytes32 name;
        address moduleAddress;
    }

    
    struct Checkpoint {
        uint256 checkpointId;
        uint256 value;
    }

    mapping (address => Checkpoint[]) public checkpointBalances;
    Checkpoint[] public checkpointTotalSupply;

    bool public finishedIssuerMinting = false;
    bool public finishedSTOMinting = false;

    mapping (bytes4 => bool) transferFunctions;

    
    mapping (uint8 => ModuleData[]) public modules;

    uint8 public constant MAX_MODULES = 20;

    mapping (address => bool) public investorListed;

    
    event LogModuleAdded(
        uint8 indexed _type,
        bytes32 _name,
        address _moduleFactory,
        address _module,
        uint256 _moduleCost,
        uint256 _budget,
        uint256 _timestamp
    );

    
    event LogUpdateTokenDetails(string _oldDetails, string _newDetails);
    
    event LogGranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);
    
    event LogModuleRemoved(uint8 indexed _type, address _module, uint256 _timestamp);
    
    event LogModuleBudgetChanged(uint8 indexed _moduleType, address _module, uint256 _budget);
    
    event LogFreezeTransfers(bool _freeze, uint256 _timestamp);
    
    event LogCheckpointCreated(uint256 indexed _checkpointId, uint256 _timestamp);
    
    event LogFinishMintingIssuer(uint256 _timestamp);
    
    event LogFinishMintingSTO(uint256 _timestamp);
    
    event LogChangeSTRAddress(address indexed _oldAddress, address indexed _newAddress);

    
    
    modifier onlyModule(uint8 _moduleType, bool _fallback) {
      
        bool isModuleType = false;
        for (uint8 i = 0; i < modules[_moduleType].length; i++) {
            isModuleType = isModuleType || (modules[_moduleType][i].moduleAddress == msg.sender);
        }
        if (_fallback && !isModuleType) {
            if (_moduleType == STO_KEY)
                require(modules[_moduleType].length == 0 && msg.sender == owner, "Sender is not owner or STO module is attached");
            else
                require(msg.sender == owner, "Sender is not owner");
        } else {
            require(isModuleType, "Sender is not correct module type");
        }
        _;
    }

    modifier checkGranularity(uint256 _amount) {
        require(_amount % granularity == 0, "Unable to modify token balances at this granularity");
        _;
    }

    
    
    modifier isMintingAllowed() {
        if (msg.sender == owner) {
            require(!finishedIssuerMinting, "Minting is finished for Issuer");
        } else {
            require(!finishedSTOMinting, "Minting is finished for STOs");
        }
        _;
    }

    








    constructor (
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _granularity,
        string _tokenDetails,
        address _polymathRegistry
    )
    public
    DetailedERC20(_name, _symbol, _decimals)
    RegistryUpdater(_polymathRegistry)
    {
        
        updateFromRegistry();
        tokenDetails = _tokenDetails;
        granularity = _granularity;
        transferFunctions[bytes4(keccak256("transfer(address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("transferFrom(address,address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("mint(address,uint256)"))] = true;
        transferFunctions[bytes4(keccak256("burn(uint256)"))] = true;
    }

    






    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external onlyOwner nonReentrant {
        _addModule(_moduleFactory, _data, _maxCost, _budget);
    }

    










    function _addModule(address _moduleFactory, bytes _data, uint256 _maxCost, uint256 _budget) internal {
        
        IModuleRegistry(moduleRegistry).useModule(_moduleFactory);
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);
        uint8 moduleType = moduleFactory.getType();
        require(modules[moduleType].length < MAX_MODULES, "Limit of MAX MODULES is reached");
        uint256 moduleCost = moduleFactory.setupCost();
        require(moduleCost <= _maxCost, "Max Cost is always be greater than module cost");
        
        require(ERC20(polyToken).approve(_moduleFactory, moduleCost), "Not able to approve the module cost");
        
        address module = moduleFactory.deploy(_data);
        
        require(ERC20(polyToken).approve(module, _budget), "Not able to approve the budget");
        
        bytes32 moduleName = moduleFactory.getName();
        modules[moduleType].push(ModuleData(moduleName, module));
        
        emit LogModuleAdded(moduleType, moduleName, _moduleFactory, module, moduleCost, _budget, now);
    }

    




    function removeModule(uint8 _moduleType, uint8 _moduleIndex) external onlyOwner {
        require(_moduleIndex < modules[_moduleType].length,
        "Module index doesn't exist as per the choosen module type");
        require(modules[_moduleType][_moduleIndex].moduleAddress != address(0),
        "Module contract address should not be 0x");
        
        emit LogModuleRemoved(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, now);
        modules[_moduleType][_moduleIndex] = modules[_moduleType][modules[_moduleType].length - 1];
        modules[_moduleType].length = modules[_moduleType].length - 1;
    }

    






    function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address) {
        if (modules[_moduleType].length > 0) {
            return (
                modules[_moduleType][_moduleIndex].name,
                modules[_moduleType][_moduleIndex].moduleAddress
            );
        } else {
            return ("", address(0));
        }

    }

    






    function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address) {
        if (modules[_moduleType].length > 0) {
            for (uint256 i = 0; i < modules[_moduleType].length; i++) {
                if (modules[_moduleType][i].name == _name) {
                  return (
                      modules[_moduleType][i].name,
                      modules[_moduleType][i].moduleAddress
                  );
                }
            }
            return ("", address(0));
        } else {
            return ("", address(0));
        }
    }

    




    function withdrawPoly(uint256 _amount) public onlyOwner {
        require(ERC20(polyToken).transfer(owner, _amount), "In-sufficient balance");
    }

    





    function changeModuleBudget(uint8 _moduleType, uint8 _moduleIndex, uint256 _budget) public onlyOwner {
        require(_moduleType != 0, "Module type cannot be zero");
        require(_moduleIndex < modules[_moduleType].length, "Incorrrect module index");
        uint256 _currentAllowance = IERC20(polyToken).allowance(address(this), modules[_moduleType][_moduleIndex].moduleAddress);
        if (_budget < _currentAllowance) {
            require(IERC20(polyToken).decreaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _currentAllowance.sub(_budget)), "Insufficient balance to decreaseApproval");
        } else {
            require(IERC20(polyToken).increaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _budget.sub(_currentAllowance)), "Insufficient balance to increaseApproval");
        }
        emit LogModuleBudgetChanged(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, _budget);
    }

    



    function updateTokenDetails(string _newTokenDetails) public onlyOwner {
        emit LogUpdateTokenDetails(tokenDetails, _newTokenDetails);
        tokenDetails = _newTokenDetails;
    }

    



    function changeGranularity(uint256 _granularity) public onlyOwner {
        require(_granularity != 0, "Granularity can not be 0");
        emit LogGranularityChanged(granularity, _granularity);
        granularity = _granularity;
    }

    





    function adjustInvestorCount(address _from, address _to, uint256 _value) internal {
        if ((_value == 0) || (_from == _to)) {
            return;
        }
        
        if ((balanceOf(_to) == 0) && (_to != address(0))) {
            investorCount = investorCount.add(1);
        }
        
        if (_value == balanceOf(_from)) {
            investorCount = investorCount.sub(1);
        }
        
        if (!investorListed[_to] && (_to != address(0))) {
            investors.push(_to);
            investorListed[_to] = true;
        }

    }

    





    function pruneInvestors(uint256 _start, uint256 _iters) public onlyOwner {
        for (uint256 i = _start; i < Math.min256(_start.add(_iters), investors.length); i++) {
            if ((i < investors.length) && (balanceOf(investors[i]) == 0)) {
                investorListed[investors[i]] = false;
                investors[i] = investors[investors.length - 1];
                investors.length--;
            }
        }
    }

    




    function getInvestorsLength() public view returns(uint256) {
        return investors.length;
    }

    


    function freezeTransfers() public onlyOwner {
        require(!freeze);
        freeze = true;
        emit LogFreezeTransfers(freeze, now);
    }

    


    function unfreezeTransfers() public onlyOwner {
        require(freeze);
        freeze = false;
        emit LogFreezeTransfers(freeze, now);
    }

    


    function adjustTotalSupplyCheckpoints() internal {
        adjustCheckpoints(checkpointTotalSupply, totalSupply());
    }

    



    function adjustBalanceCheckpoints(address _investor) internal {
        adjustCheckpoints(checkpointBalances[_investor], balanceOf(_investor));
    }

    




    function adjustCheckpoints(Checkpoint[] storage _checkpoints, uint256 _newValue) internal {
        
        if (currentCheckpointId == 0) {
            return;
        }
        
        if (_checkpoints.length == 0) {
            _checkpoints.push(
                Checkpoint({
                    checkpointId: currentCheckpointId,
                    value: _newValue
                })
            );
            return;
        }
        
        if (_checkpoints[_checkpoints.length - 1].checkpointId == currentCheckpointId) {
            return;
        }
        
        _checkpoints.push(
            Checkpoint({
                checkpointId: currentCheckpointId,
                value: _newValue
            })
        );
    }

    





    function transfer(address _to, uint256 _value) public returns (bool success) {
        adjustInvestorCount(msg.sender, _to, _value);
        require(verifyTransfer(msg.sender, _to, _value), "Transfer is not valid");
        adjustBalanceCheckpoints(msg.sender);
        adjustBalanceCheckpoints(_to);
        require(super.transfer(_to, _value));
        return true;
    }

    






    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        adjustInvestorCount(_from, _to, _value);
        require(verifyTransfer(_from, _to, _value), "Transfer is not valid");
        adjustBalanceCheckpoints(_from);
        adjustBalanceCheckpoints(_to);
        require(super.transferFrom(_from, _to, _value));
        return true;
    }

    







    function verifyTransfer(address _from, address _to, uint256 _amount) public checkGranularity(_amount) returns (bool) {
        if (!freeze) {
            bool isTransfer = false;
            if (transferFunctions[getSig(msg.data)]) {
              isTransfer = true;
            }
            if (modules[TRANSFERMANAGER_KEY].length == 0) {
                return true;
            }
            bool isInvalid = false;
            bool isValid = false;
            bool isForceValid = false;
            for (uint8 i = 0; i < modules[TRANSFERMANAGER_KEY].length; i++) {
                ITransferManager.Result valid = ITransferManager(modules[TRANSFERMANAGER_KEY][i].moduleAddress).verifyTransfer(_from, _to, _amount, isTransfer);
                if (valid == ITransferManager.Result.INVALID) {
                    isInvalid = true;
                }
                if (valid == ITransferManager.Result.VALID) {
                    isValid = true;
                }
                if (valid == ITransferManager.Result.FORCE_VALID) {
                    isForceValid = true;
                }
            }
            return isForceValid ? true : (isInvalid ? false : isValid);
      }
      return false;
    }

    


    function finishMintingIssuer() public onlyOwner {
        finishedIssuerMinting = true;
        emit LogFinishMintingIssuer(now);
    }

    


    function finishMintingSTO() public onlyOwner {
        finishedSTOMinting = true;
        emit LogFinishMintingSTO(now);
    }

    






    function mint(address _investor, uint256 _amount) public onlyModule(STO_KEY, true) checkGranularity(_amount) isMintingAllowed() returns (bool success) {
        require(_investor != address(0), "Investor address should not be 0x");
        adjustInvestorCount(address(0), _investor, _amount);
        require(verifyTransfer(address(0), _investor, _amount), "Transfer is not valid");
        adjustBalanceCheckpoints(_investor);
        adjustTotalSupplyCheckpoints();
        totalSupply_ = totalSupply_.add(_amount);
        balances[_investor] = balances[_investor].add(_amount);
        emit Minted(_investor, _amount);
        emit Transfer(address(0), _investor, _amount);
        return true;
    }

    






    function mintMulti(address[] _investors, uint256[] _amounts) public onlyModule(STO_KEY, true) returns (bool success) {
        require(_investors.length == _amounts.length, "Mis-match in the length of the arrays");
        for (uint256 i = 0; i < _investors.length; i++) {
            mint(_investors[i], _amounts[i]);
        }
        return true;
    }

    








    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool) {
        if (modules[PERMISSIONMANAGER_KEY].length == 0) {
            return false;
        }

        for (uint8 i = 0; i < modules[PERMISSIONMANAGER_KEY].length; i++) {
            if (IPermissionManager(modules[PERMISSIONMANAGER_KEY][i].moduleAddress).checkPermission(_delegate, _module, _perm)) {
                return true;
            }
        }
    }

    



    function setTokenBurner(address _tokenBurner) public onlyOwner {
        tokenBurner = ITokenBurner(_tokenBurner);
    }

    



    function burn(uint256 _value) checkGranularity(_value) public {
        adjustInvestorCount(msg.sender, address(0), _value);
        require(tokenBurner != address(0), "Token Burner contract address is not set yet");
        require(verifyTransfer(msg.sender, address(0), _value), "Transfer is not valid");
        require(_value <= balances[msg.sender], "Value should no be greater than the balance of msg.sender");
        adjustBalanceCheckpoints(msg.sender);
        adjustTotalSupplyCheckpoints();
        
        

        balances[msg.sender] = balances[msg.sender].sub(_value);
        require(tokenBurner.burn(msg.sender, _value), "Token burner process is not validated");
        totalSupply_ = totalSupply_.sub(_value);
        emit Burnt(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }

    




    function getSig(bytes _data) internal pure returns (bytes4 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }

    



    function createCheckpoint() public onlyModule(CHECKPOINT_KEY, true) returns(uint256) {
        require(currentCheckpointId < 2**256 - 1);
        currentCheckpointId = currentCheckpointId + 1;
        emit LogCheckpointCreated(currentCheckpointId, now);
        return currentCheckpointId;
    }

    




    function totalSupplyAt(uint256 _checkpointId) public view returns(uint256) {
        return getValueAt(checkpointTotalSupply, _checkpointId, totalSupply());
    }

    






    function getValueAt(Checkpoint[] storage checkpoints, uint256 _checkpointId, uint256 _currentValue) internal view returns(uint256) {
        require(_checkpointId <= currentCheckpointId);
        
        if (_checkpointId == 0) {
          return 0;
        }
        if (checkpoints.length == 0) {
            return _currentValue;
        }
        if (checkpoints[0].checkpointId >= _checkpointId) {
            return checkpoints[0].value;
        }
        if (checkpoints[checkpoints.length - 1].checkpointId < _checkpointId) {
            return _currentValue;
        }
        if (checkpoints[checkpoints.length - 1].checkpointId == _checkpointId) {
            return checkpoints[checkpoints.length - 1].value;
        }
        uint256 min = 0;
        uint256 max = checkpoints.length - 1;
        while (max > min) {
            uint256 mid = (max + min) / 2;
            if (checkpoints[mid].checkpointId == _checkpointId) {
                max = mid;
                break;
            }
            if (checkpoints[mid].checkpointId < _checkpointId) {
                min = mid + 1;
            } else {
                max = mid;
            }
        }
        return checkpoints[max].value;
    }

    




    function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256) {
        return getValueAt(checkpointBalances[_investor], _checkpointId, balanceOf(_investor));
    }

}



