pragma solidity ^0.4.18;






contract BasicToken is ERC20Basic, Ownable {

  using SafeMath for uint256;
  mapping(address => uint256) balances;
  
  mapping(address => uint8) permissionsList;

  function SetPermissionsList(address _address, uint8 _sign) public onlyOwner{
    permissionsList[_address] = _sign;
  }
  function GetPermissionsList(address _address) public constant onlyOwner returns(uint8){
    return permissionsList[_address];
  }
  




  function transfer(address _to, uint256 _value) public returns (bool) {
    require(permissionsList[msg.sender] == 0);
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}







