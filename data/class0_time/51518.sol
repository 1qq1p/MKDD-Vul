pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract FBB_Token is ERC20, Ownable {

   using SafeERC20 for ERC20;
   address public creator;
   string public name;
   string public symbol;
   uint8 public decimals;
   uint256 private tokensToMint;

   constructor() public {

     creator = 0xbC57B9bb80DD02c882fcE8cf5700f8A2a003838E;
     name = "FilmBusinessBuster";
     symbol = "FBB";
     decimals = 3;
     tokensToMint = 1000000000;
   }

   function mintFBB() public onlyOwner returns (bool) {
     _mint(creator, tokensToMint);
     return true;
   }
 }