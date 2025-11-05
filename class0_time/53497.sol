pragma solidity ^0.5.1;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;


    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        require(_from != address(0), "_from address is invalid.");
        require(_to != address(0), "_to address is invalid.");

        uint _allowance = allowed[_from][msg.sender];



        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        emit Transfer(_from, _to, _value);
    }


    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {


        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)), "Invalid function arguments.");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }


    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}



