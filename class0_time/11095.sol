pragma solidity ^0.4.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract GVE is StandardToken, Ownable {
    string  public  constant name = "Globalvillage ecosystem";
    string  public  constant symbol = "GVE";
    uint    public  constant decimals = 18;

    bool public transferEnabled = true;


    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    function GVE() {
        
        totalSupply = 1000000000 * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);
        transferOwnership(msg.sender); 
    }

    function transfer(address _to, uint _value)
    validDestination(_to)
    returns (bool) {
        require(transferEnabled == true);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value)
    validDestination(_to)
    returns (bool) {
        require(transferEnabled == true);
        return super.transferFrom(_from, _to, _value);
    }


    function emergencyERC20Drain( ERC20 token, uint amount ) onlyOwner {
        token.transfer( owner, amount );
    }

    function setTransferEnable(bool enable) onlyOwner {
        transferEnabled = enable;
    }
}