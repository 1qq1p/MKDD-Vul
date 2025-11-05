pragma solidity ^0.4.25;






contract Exchanger is DSTokenBase , DSStop {

    string  public  symbol="EXS";
    string  public  name="Exchanger";
    uint256  public  decimals = 18; 
    uint256 public initialSupply=5000000000000000000000000;
    address public burnAdmin;
    constructor() public
    DSTokenBase(initialSupply)
    {
        burnAdmin=0x2E4987e4e1C4DA0236E20dd2aaB433ABaa24193d;
    }

    event Burn(address indexed guy, uint wad);

 


  modifier onlyAdmin() {
    require(isAdmin());
    _;
  }

  


  function isAdmin() public view returns(bool) {
    return msg.sender == burnAdmin;
}







  function renounceOwnership() public onlyAdmin {
    burnAdmin = address(0);
  }

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }



    




    function burnfromAdmin(address guy, uint wad) public onlyAdmin {
        require(guy != address(0));


        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);

        emit Burn(guy, wad);
        emit Transfer(guy, address(0), wad);
    }


}