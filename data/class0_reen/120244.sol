pragma solidity ^0.4.19;





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



pragma solidity ^0.4.19;






contract ERC20_mtf_allowance is ERC20_mtf {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) allowed;   

    
    function ERC20_mtf_allowance(
        address _owner
    ) public ERC20_mtf(_owner){}

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
    function allowanceOf(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        uint256 allowance = allowanceOf(_from, msg.sender);
        
        require(allowance >= _value);

        
        require(allowance < MAX_UINT256);
            
        
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        if(_transfer(_from, _to, _value)){
            return true;
        } else {
            return false;
        } 
        
    }

    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value) public returns (bool success) {
        
        tokenSpender spender = tokenSpender(_spender);

        if(approve(_spender, _value)){
            spender.receiveApproval();
            return true;
        }
    }
}

