pragma solidity ^0.4.18;

















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









contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  


  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  


  modifier whenPaused() {
    require(paused);
    _;
  }

  


  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  


  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


















interface ERC20Token {

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



interface ERC223 {

    function totalSupply() public constant returns (uint);
    function balanceOf(address who) public constant returns (uint);
    function transfer(address to, uint value) public returns (bool);

}






 