pragma solidity ^0.4.18;
    library SafeMath {
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a * b;
            assert(a == 0 || c / a == b);
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
    library ERC20Interface {
        function totalSupply() public constant returns (uint);
        function balanceOf(address tokenOwner) public constant returns (uint balance);
        function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
        function transfer(address to, uint tokens) public returns (bool success);
        function approve(address spender, uint tokens) public returns (bool success);
        function transferFrom(address from, address to, uint tokens) public returns (bool success);
        event Transfer(address indexed from, address indexed to, uint tokens);
        event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    }
    library ApproveAndCallFallBack {
        function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
    }
contract owned {
    
    
    	    address public owner;
    
    
    	    function owned() payable public {
    	        owner = msg.sender;
    	    }
    	    
    	    modifier onlyOwner {
    	        require(owner == msg.sender);
    	        _;
    	    }
    
    
    	    function changeOwner(address _owner) onlyOwner public {
    	        owner = _owner;
    	    }
    	}