pragma solidity 0.4.18;






library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint256) {
        uint c = a / b;
        return c;
    }

    function sub(uint256 a, uint b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint a, uint b) internal pure returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}







contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    
    uint64 public dateTransferable = 1518825600;

    




    function transfer(address _to, uint256 _value) public returns (bool) {
        uint64 _now = uint64(block.timestamp);
        require(_now >= dateTransferable);
        require(_to != address(this)); 
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    




    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }
}





