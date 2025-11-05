pragma solidity ^0.5.0;









contract AccessDelegated {

  








    mapping(address => uint256) public accessLevel;

    event AccessLevelSet(
        address accessSetFor,
        uint256 accessLevel,
        address setBy
    );
    event AccessRevoked(
        address accessRevoked,
        uint256 previousAccessLevel,
        address revokedBy
    );


    



    constructor() public {
        accessLevel[msg.sender] = 4;
    }

    

    modifier requiresNoAccessLevel () {
        require(
            accessLevel[msg.sender] >= 0,
            "Access level greater than or equal to 0 required"
        );
        _;
    }

    modifier requiresLimitedAccessLevel () {
        require(
            accessLevel[msg.sender] >= 1,
            "Access level greater than or equal to 1 required"
        );
        _;
    }

    modifier requiresPrivelegedAccessLevel () {
        require(
            accessLevel[msg.sender] >= 2,
            "Access level greater than or equal to 2 required"
        );
        _;
    }

    modifier requiresManagerAccessLevel () {
        require(
            accessLevel[msg.sender] >= 3,
            "Access level greater than or equal to 3 required"
        );
        _;
    }

    modifier requiresOwnerAccessLevel () {
        require(
            accessLevel[msg.sender] >= 4,
            "Access level greater than or equal to 4 required"
        );
        _;
    }

    

    modifier limitedAccessLevelOnly () {
        require(accessLevel[msg.sender] == 1, "Access level 1 required");
        _;
    }

    modifier privelegedAccessLevelOnly () {
        require(accessLevel[msg.sender] == 2, "Access level 2 required");
        _;
    }

    modifier managerAccessLevelOnly () {
        require(accessLevel[msg.sender] == 3, "Access level 3 required");
        _;
    }

    modifier adminAccessLevelOnly () {
        require(accessLevel[msg.sender] == 4, "Access level 4 required");
        _;
    }


    





    function setAccessLevel(
        address _user,
        uint256 _access
    )
        public
        adminAccessLevelOnly
    {
        require(
            accessLevel[_user] < 4,
            "Cannot setAccessLevel for Admin Level Access User"
        ); 

        if (_access < 0 || _access > 4) {
            revert("erroneous access level");
        } else {
            accessLevel[_user] = _access;
        }

        emit AccessLevelSet(_user, _access, msg.sender);
    }

    function revokeAccess(address _user) public adminAccessLevelOnly {
        
        require(
            accessLevel[_user] < 4,
            "admin cannot revoke their own access"
        );
        uint256 currentAccessLevel = accessLevel[_user];
        accessLevel[_user] = 0;

        emit AccessRevoked(_user, currentAccessLevel, msg.sender);
    }

    




    function getAccessLevel(address _user) public view returns (uint256) {
        return accessLevel[_user];
    }

    



    function myAccessLevel() public view returns (uint256) {
        return getAccessLevel(msg.sender);
    }

}












