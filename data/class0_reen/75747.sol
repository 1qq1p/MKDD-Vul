


pragma solidity ^0.5.0;






contract UniversalScheme is UniversalSchemeInterface {
    


    function getParametersFromController(Avatar _avatar) internal view returns(bytes32) {
        require(ControllerInterface(_avatar.owner()).isSchemeRegistered(address(this), address(_avatar)),
        "scheme is not registered");
        return ControllerInterface(_avatar.owner()).getSchemeParameters(address(this), address(_avatar));
    }
}



pragma solidity ^0.5.4;











