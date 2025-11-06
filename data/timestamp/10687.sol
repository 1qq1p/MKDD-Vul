pragma solidity 0.4.18;









library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    


    function add(Role storage role, address addr)
        internal
    {
        role.bearer[addr] = true;
    }

    


    function remove(Role storage role, address addr)
        internal
    {
        role.bearer[addr] = false;
    }

    



    function check(Role storage role, address addr)
        view
        internal
    {
        require(has(role, addr));
    }

    



    function has(Role storage role, address addr)
        view
        internal
        returns (bool)
    {
        return role.bearer[addr];
    }
}














contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    



    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        
        

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}






