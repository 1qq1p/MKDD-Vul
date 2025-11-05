pragma solidity ^0.4.24;




contract ModuleFactory is IModuleFactory, Ownable {

    IERC20 public polyToken;
    uint256 public usageCost;
    uint256 public monthlySubscriptionCost;

    uint256 public setupCost;
    string public description;
    string public version;
    bytes32 public name;
    string public title;

    
    
    
    
    
    mapping(string => uint24) compatibleSTVersionRange;

    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    



    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
        polyToken = IERC20(_polyAddress);
        setupCost = _setupCost;
        usageCost = _usageCost;
        monthlySubscriptionCost = _subscriptionCost;
    }

    



    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {
        emit ChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
        setupCost = _newSetupCost;
    }

    



    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {
        emit ChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
        usageCost = _newUsageCost;
    }

    



    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {
        emit ChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
        monthlySubscriptionCost = _newSubscriptionCost;

    }

    



    function changeTitle(string _newTitle) public onlyOwner {
        require(bytes(_newTitle).length > 0, "Invalid title");
        title = _newTitle;
    }

    



    function changeDescription(string _newDesc) public onlyOwner {
        require(bytes(_newDesc).length > 0, "Invalid description");
        description = _newDesc;
    }

    



    function changeName(bytes32 _newName) public onlyOwner {
        require(_newName != bytes32(0),"Invalid name");
        name = _newName;
    }

    



    function changeVersion(string _newVersion) public onlyOwner {
        require(bytes(_newVersion).length > 0, "Invalid version");
        version = _newVersion;
    }

    




    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external onlyOwner {
        require(
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("lowerBound")) ||
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("upperBound")),
            "Must be a valid bound type"
        );
        require(_newVersion.length == 3);
        if (compatibleSTVersionRange[_boundType] != uint24(0)) { 
            uint8[] memory _currentVersion = VersionUtils.unpack(compatibleSTVersionRange[_boundType]);
            require(VersionUtils.isValidVersion(_currentVersion, _newVersion), "Failed because of in-valid version");
        }
        compatibleSTVersionRange[_boundType] = VersionUtils.pack(_newVersion[0], _newVersion[1], _newVersion[2]);
        emit ChangeSTVersionBound(_boundType, _newVersion[0], _newVersion[1], _newVersion[2]);
    }

    



    function getLowerSTVersionBounds() external view returns(uint8[]) {
        return VersionUtils.unpack(compatibleSTVersionRange["lowerBound"]);
    }

    



    function getUpperSTVersionBounds() external view returns(uint8[]) {
        return VersionUtils.unpack(compatibleSTVersionRange["upperBound"]);
    }

    


    function getSetupCost() external view returns (uint256) {
        return setupCost;
    }

   


    function getName() public view returns(bytes32) {
        return name;
    }

}




library Util {

   



    function upper(string _base) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1)-32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

    



    
    function stringToBytes32(string memory _source) internal pure returns (bytes32) {
        return bytesToBytes32(bytes(_source), 0);
    }

    




    
    function bytesToBytes32(bytes _b, uint _offset) internal pure returns (bytes32) {
        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

    



    function bytes32ToString(bytes32 _source) internal pure returns (string result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    




    function getSig(bytes _data) internal pure returns (bytes4 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }


}



