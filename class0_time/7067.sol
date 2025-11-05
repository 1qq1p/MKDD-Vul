pragma solidity ^0.4.11;





library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}






contract TKRToken is StandardToken {
    event Destroy(address indexed _from, address indexed _to, uint256 _value);

    string public name = "TKRToken";
    string public symbol = "TKR";
    uint256 public decimals = 18;
    uint256 public initialSupply = 65500000 * 10 ** 18;

    


    function TKRToken() {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
    }

    



    function destroy(uint256 _value) onlyOwner returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Destroy(msg.sender, 0x0, _value);
    }
}