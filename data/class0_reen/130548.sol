pragma solidity ^0.4.24;




contract Pausable {

    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    


    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    


    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

   


    function _pause() internal whenNotPaused {
        paused = true;
        
        emit Pause(now);
    }

    


    function _unpause() internal whenPaused {
        paused = false;
        
        emit Unpause(now);
    }

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





