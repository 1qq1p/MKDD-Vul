pragma solidity ^0.4.13;

contract Upgradable is Ownable {

    address public newAddress;
    uint    public deprecatedSince;
    string  public version;
    string  public newVersion;
    string  public reason;

    event LogSetDeprecated(address newAddress, string newVersion, string reason);

    


    function Upgradable(string _version) internal
    {
        version = _version;
    }

    


    function setDeprecated(address _newAddress, string _newVersion, string _reason) external
        ownerOnly
        returns (bool success)
    {
        require(!isDeprecated());
        require(_newAddress != address(this));
        require(!Upgradable(_newAddress).isDeprecated());
        deprecatedSince = now;
        newAddress = _newAddress;
        newVersion = _newVersion;
        reason = _reason;
        emit LogSetDeprecated(_newAddress, _newVersion, _reason);
        return true;
    }

    


    function isDeprecated() public view returns (bool deprecated)
    {
        return (deprecatedSince != 0);
    }
}
