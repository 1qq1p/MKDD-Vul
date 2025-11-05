pragma solidity ^0.4.24;




interface IUSDTieredSTOProxy {

   






    function deploySTO(address _securityToken, address _polyAddress, address _factoryAddress) external returns (address);
    
     




    function getInitFunction(address _contractAddress) external returns (bytes4);

}





interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




interface IModuleFactory {

    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    
    function deploy(bytes _data) external returns(address);

    


    function getTypes() external view returns(uint8[]);

    


    function getName() external view returns(bytes32);

    


    function getInstructions() external view returns (string);

    


    function getTags() external view returns (bytes32[]);

    



    function changeFactorySetupFee(uint256 _newSetupCost) external;

    



    function changeFactoryUsageFee(uint256 _newUsageCost) external;

    



    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) external;

    




    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external;

   


    function getSetupCost() external view returns (uint256);

    



    function getLowerSTVersionBounds() external view returns(uint8[]);

     



    function getUpperSTVersionBounds() external view returns(uint8[]);

}






contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  



  constructor() public {
    owner = msg.sender;
  }

  


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  


  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  



  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  



  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}





library VersionUtils {

    





    function isValidVersion(uint8[] _current, uint8[] _new) internal pure returns(bool) {
        bool[] memory _temp = new bool[](_current.length);
        uint8 counter = 0;
        for (uint8 i = 0; i < _current.length; i++) {
            if (_current[i] < _new[i])
                _temp[i] = true;
            else
                _temp[i] = false;
        }

        for (i = 0; i < _current.length; i++) {
            if (i == 0) {
                if (_current[i] <= _new[i])
                    if(_temp[0]) {
                        counter = counter + 3;
                        break;
                    } else
                        counter++;
                else
                    return false;
            } else {
                if (_temp[i-1])
                    counter++;
                else if (_current[i] <= _new[i])
                    counter++;
                else
                    return false;
            }
        }
        if (counter == _current.length)
            return true;
    }

    





    function compareLowerBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {
        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version2[i] > _version1[i])
                    return true;
                else if (_version2[i] < _version1[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }

    





    function compareUpperBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {
        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version1[i] > _version2[i])
                    return true;
                else if (_version1[i] < _version2[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }


    





    function pack(uint8 _major, uint8 _minor, uint8 _patch) internal pure returns(uint24) {
        return (uint24(_major) << 16) | (uint24(_minor) << 8) | uint24(_patch);
    }

    



    function unpack(uint24 _packedVersion) internal pure returns (uint8[]) {
        uint8[] memory _unpackVersion = new uint8[](3);
        _unpackVersion[0] = uint8(_packedVersion >> 16);
        _unpackVersion[1] = uint8(_packedVersion >> 8);
        _unpackVersion[2] = uint8(_packedVersion);
        return _unpackVersion;
    }


}




