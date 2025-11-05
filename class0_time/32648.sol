pragma solidity ^0.4.24;

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

contract RBAC {
    using Roles for Roles.Role;
    mapping (string => Roles.Role) private roles;
    event RoleAdded(address indexed operator, string role);
    event RoleRemoved(address indexed operator, string role);

    function checkRole(address _operator, string _role)
    view
    public
    {
        roles[_role].check(_operator);
    }

    function hasRole(address _operator, string _role)
    view
    public
    returns (bool)
    {
        return roles[_role].has(_operator);
    }

    function addRole(address _operator, string _role)
    internal
    {
        roles[_role].add(_operator);
        emit RoleAdded(_operator, _role);
    }

    function removeRole(address _operator, string _role)
    internal
    {
        roles[_role].remove(_operator);
        emit RoleRemoved(_operator, _role);
    }

    modifier onlyRole(string _role)
    {
        checkRole(msg.sender, _role);
        _;
    }
}
