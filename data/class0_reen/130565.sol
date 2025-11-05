pragma solidity ^0.5.9;





library Math {



function max(uint256 a, uint256 b) internal pure returns (uint256) {
return a >= b ? a : b;
}




function min(uint256 a, uint256 b) internal pure returns (uint256) {
return a < b ? a : b;
}






function average(uint256 a, uint256 b) internal pure returns (uint256) {

return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
}
}






library Roles {
struct Role {
mapping (address => bool) bearer;
}




function add(Role storage role, address account) internal {
require(account != address(0));
require(!has(role, account));

role.bearer[account] = true;
}




function remove(Role storage role, address account) internal {
require(account != address(0));
require(has(role, account));

role.bearer[account] = false;
}





function has(Role storage role, address account) internal view returns (bool) {
require(account != address(0));
return role.bearer[account];
}
}






library SafeMath {



function mul(uint256 a, uint256 b) internal pure returns (uint256) {



if (a == 0) {
return 0;
}

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




contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
}


















