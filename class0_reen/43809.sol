pragma solidity ^0.4.24;





interface ICheckpoint {

}




interface IModule {

    


    function getInitFunction() external pure returns (bytes4);

    


    function getPermissions() external view returns(bytes32[]);

    


    function takeFee(uint256 _amount) external returns(bool);

}




interface ISecurityToken {

    
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

    
    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);

    





    function mint(address _investor, uint256 _value) external returns (bool success);

    






    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);

    





    function burnFromWithData(address _from, uint256 _value, bytes _data) external;

    




    function burnWithData(uint256 _value, bytes _data) external;

    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    
    
    
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);

    











    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);

    




    function getModulesByName(bytes32 _name) external view returns (address[]);

    




    function getModulesByType(uint8 _type) external view returns (address[]);

    



    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);

    




    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);

    


    function createCheckpoint() external returns (uint256);

    




    function getInvestors() external view returns (address[]);

    





    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);

    






    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);
    
    



    function currentCheckpointId() external view returns (uint256);

    




    function investors(uint256 _index) external view returns (address);

   





    function withdrawERC20(address _tokenContract, uint256 _value) external;

    




    function changeModuleBudget(address _module, uint256 _budget) external;

    



    function updateTokenDetails(string _newTokenDetails) external;

    



    function changeGranularity(uint256 _granularity) external;

    





    function pruneInvestors(uint256 _start, uint256 _iters) external;

    


    function freezeTransfers() external;

    


    function unfreezeTransfers() external;

    


    function freezeMinting() external;

    






    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);

    










    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;

    



    function archiveModule(address _module) external;

    



    function unarchiveModule(address _module) external;

    



    function removeModule(address _module) external;

    



    function setController(address _controller) external;

    







    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;

    






    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;

    



     function disableController() external;

     


     function getVersion() external view returns(uint8[]);

     


     function getInvestorCount() external view returns(uint256);

     






     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);

     







     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);

     



     function granularity() external view returns(uint256);
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






contract Module is IModule {

    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

    




    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }

    
    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {
        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    


    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
    }
}





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    
    
    
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}





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



















