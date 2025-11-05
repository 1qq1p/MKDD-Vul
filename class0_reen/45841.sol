pragma solidity ^0.4.24;

interface IOracle {

    


    function getCurrencyAddress() external view returns(address);

    


    function getCurrencySymbol() external view returns(bytes32);

    


    function getCurrencyDenominated() external view returns(bytes32);

    


    function getPrice() external view returns(uint256);

}














contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        assert(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier authorized(bytes4 sig) {
        assert(isAuthorized(msg.sender, sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal returns (bool) {
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

    function assert(bool x) internal {
        if (!x) throw;
    }
}
