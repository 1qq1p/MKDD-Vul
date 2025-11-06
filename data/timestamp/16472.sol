pragma solidity ^0.4.24;





library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
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




interface IModule {

    


    function getInitFunction() external pure returns (bytes4);

    


    function getPermissions() external view returns(bytes32[]);

    


    function takeFee(uint256 _amount) external returns(bool);

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




interface IModuleRegistry {

    



    function useModule(address _moduleFactory) external;

    



    function registerModule(address _moduleFactory) external;

    



    function removeModule(address _moduleFactory) external;

    





    function verifyModule(address _moduleFactory, bool _verified) external;

    




    function getReputationByFactory(address _factoryAddress) external view returns(address[]);

    






    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[], address[]);

    





    function getTagsByType(uint8 _moduleType) external view returns(bytes32[], address[]);

    




    function getModulesByType(uint8 _moduleType) external view returns(address[]);

    





    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns (address[]);

    


    function updateFromRegistry() external;

    



    function owner() external view returns(address);

    



    function isPaused() external view returns(bool);

}




interface IFeatureRegistry {

    




    function getFeatureStatus(string _nameKey) external view returns(bool);

}




contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  





  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  









  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  





  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  









  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  









  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






