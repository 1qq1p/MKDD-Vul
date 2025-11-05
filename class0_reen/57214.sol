pragma solidity ^0.5.0;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    


    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    



    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract SesameChainToken is ERC20, ERC20Detailed, ERC20Capped, ERC20Pausable {

    constructor(
    )
        ERC20Detailed('Sesamechain', 'LSC', 18)
        ERC20Capped(1*(10**9)*(10**18))
        ERC20()
        ERC20Pausable()
        public
        payable
    {}

}