pragma solidity 0.4.24;




library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
  }

}






contract ERC20Interface {
  
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function burn(uint256 tokens) public returns (bool success);
    function freeze(uint256 tokens) public returns (bool success);
    function unfreeze(uint256 tokens) public returns (bool success);


    
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    
    event Burn(address indexed from, uint256 tokens);
    
    
    event Freeze(address indexed from, uint256 tokens);
	
    
    event Unfreeze(address indexed from, uint256 tokens);
 }
 


