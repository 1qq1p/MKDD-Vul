

pragma solidity ^0.5.0;






contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    



    function when() public returns(CallPhase);
}



pragma solidity ^0.5.4;









interface ControllerInterface {

    





    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    returns(bool);

    





    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    returns(bool);

    






    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    returns(bool);

  







    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    returns(bool);

    





    function unregisterScheme(address _scheme, address _avatar)
    external
    returns(bool);

    




    function unregisterSelf(address _avatar) external returns(bool);

    






    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external returns(bool);

    





    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external  returns(bool);

  






    function upgradeController(address _newController, Avatar _avatar)
    external returns(bool);

    







    function genericCall(address _contract, bytes calldata _data, Avatar _avatar)
    external
    returns(bool, bytes memory);

  






    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external returns(bool);

    







    function externalTokenTransfer(IERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    










    function externalTokenTransferFrom(
    IERC20 _externalToken,
    address _from,
    address _to,
    uint256 _value,
    Avatar _avatar)
    external
    returns(bool);

    







    function externalTokenApproval(IERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    





    function metaData(string calldata _metaData, Avatar _avatar) external returns(bool);

    




    function getNativeReputation(address _avatar)
    external
    view
    returns(address);

    function isSchemeRegistered( address _scheme, address _avatar) external view returns(bool);

    function getSchemeParameters(address _scheme, address _avatar) external view returns(bytes32);

    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32);

    function getSchemePermissions(address _scheme, address _avatar) external view returns(bytes4);

    




    function globalConstraintsCount(address _avatar) external view returns(uint, uint);

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar) external view returns(bool);
}



pragma solidity ^0.5.4;











