pragma solidity ^0.4.23;

library SafeMath{
    
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256 result){
        if(_y == 0){
            return 0;
        }
        result = _x*_y;
        assert(_x == result/_y);
        return result;
    }
    
    function div(uint256 _x, uint256 _y) internal pure returns (uint256 result){
        result = _x / _y;
        return result;
    }
    
    function add(uint256 _x, uint256 _y) internal pure returns (uint256 result){
        result = _x + _y;
        assert(result >= _x);
        return result;
    }
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256 result){
        assert(_x >= _y);
        result = _x - _y;
        return result;
    }
}
interface ReceiverContract{
    function tokenFallback(address _sender, uint256 _amount, bytes _data) external;
}


contract ERC20Interface {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}