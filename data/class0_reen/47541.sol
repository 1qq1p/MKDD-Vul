pragma solidity ^0.4.25;








contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = 0x97928f63662795c07D05A21c89F0d62A26078AE5;
        emit LogSetOwner(0x97928f63662795c07D05A21c89F0d62A26078AE5);
    }

    function setOwner(address owner_0x97928f63662795c07D05A21c89F0d62A26078AE5)
        public
        auth
    {
        owner = owner_0x97928f63662795c07D05A21c89F0d62A26078AE5;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

