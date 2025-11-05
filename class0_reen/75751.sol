


pragma solidity ^0.5.0;






contract DaoCreator {

    mapping(address=>address) public locks;

    event NewOrg (address _avatar);
    event InitialSchemesSet (address _avatar);

    ControllerCreator private controllerCreator;

    constructor(ControllerCreator _controllerCreator) public {
        controllerCreator = _controllerCreator;
    }

    










    function addFounders (
        Avatar _avatar,
        address[] calldata _founders,
        uint[] calldata _foundersTokenAmount,
        uint[] calldata _foundersReputationAmount
    )
    external
    returns(bool)
    {
        require(_founders.length == _foundersTokenAmount.length);
        require(_founders.length == _foundersReputationAmount.length);
        require(_founders.length > 0);
        require(locks[address(_avatar)] == msg.sender);
        
        for (uint256 i = 0; i < _founders.length; i++) {
            require(_founders[i] != address(0));
            if (_foundersTokenAmount[i] > 0) {
                ControllerInterface(
                _avatar.owner()).mintTokens(_foundersTokenAmount[i], _founders[i], address(_avatar));
            }
            if (_foundersReputationAmount[i] > 0) {
                ControllerInterface(
                _avatar.owner()).mintReputation(_foundersReputationAmount[i], _founders[i], address(_avatar));
            }
        }
        return true;
    }

  














    function forgeOrg (
        string calldata _orgName,
        string calldata _tokenName,
        string calldata _tokenSymbol,
        address[] calldata _founders,
        uint[] calldata _foundersTokenAmount,
        uint[] calldata _foundersReputationAmount,
        UController _uController,
        uint256 _cap
    )
    external
    returns(address)
    {
        
        return _forgeOrg(
            _orgName,
            _tokenName,
            _tokenSymbol,
            _founders,
            _foundersTokenAmount,
            _foundersReputationAmount,
            _uController,
            _cap);
    }

     







    function setSchemes (
        Avatar _avatar,
        address[] calldata _schemes,
        bytes32[] calldata _params,
        bytes4[] calldata _permissions,
        string calldata _metaData
    )
        external
    {
        
        
        require(locks[address(_avatar)] == msg.sender);
        
        ControllerInterface controller = ControllerInterface(_avatar.owner());
        for (uint256 i = 0; i < _schemes.length; i++) {
            controller.registerScheme(_schemes[i], _params[i], _permissions[i], address(_avatar));
        }
        controller.metaData(_metaData, _avatar);
        
        controller.unregisterScheme(address(this), address(_avatar));
        
        delete locks[address(_avatar)];
        emit InitialSchemesSet(address(_avatar));
    }

    














    function _forgeOrg (
        string memory _orgName,
        string memory _tokenName,
        string memory _tokenSymbol,
        address[] memory _founders,
        uint[] memory _foundersTokenAmount,
        uint[] memory _foundersReputationAmount,
        UController _uController,
        uint256 _cap
    ) private returns(address)
    {
        
        require(_founders.length == _foundersTokenAmount.length);
        require(_founders.length == _foundersReputationAmount.length);
        require(_founders.length > 0);
        DAOToken  nativeToken = new DAOToken(_tokenName, _tokenSymbol, _cap);
        Reputation  nativeReputation = new Reputation();
        Avatar  avatar = new Avatar(_orgName, nativeToken, nativeReputation);
        ControllerInterface  controller;

        
        for (uint256 i = 0; i < _founders.length; i++) {
            require(_founders[i] != address(0));
            if (_foundersTokenAmount[i] > 0) {
                nativeToken.mint(_founders[i], _foundersTokenAmount[i]);
            }
            if (_foundersReputationAmount[i] > 0) {
                nativeReputation.mint(_founders[i], _foundersReputationAmount[i]);
            }
        }

        
        if (UController(0) == _uController) {
            controller = ControllerInterface(controllerCreator.create(avatar));
            avatar.transferOwnership(address(controller));
            
            nativeToken.transferOwnership(address(controller));
            nativeReputation.transferOwnership(address(controller));
        } else {
            controller = _uController;
            avatar.transferOwnership(address(controller));
            
            nativeToken.transferOwnership(address(controller));
            nativeReputation.transferOwnership(address(controller));
            _uController.newOrganization(avatar);
        }

        locks[address(avatar)] = msg.sender;

        emit NewOrg (address(avatar));
        return (address(avatar));
    }
}
