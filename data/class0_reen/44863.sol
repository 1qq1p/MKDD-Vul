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








contract CogeneroToken is MintableToken {
  function allowTransfer(address _from, address _to) public view returns (bool);
  function allowManager() public view returns (bool);
  function setManager(address _manager, bool _status) onlyOwner public;
  function setAllowTransferGlobal(bool _status) public;
  function setAllowTransferLocal(bool _status) public;
  function setAllowTransferExternal(bool _status) public;
  function setWhitelist(address _address, uint256 _date) public;
  function setLockupList(address _address, uint256 _date) public;
  function setWildcardList(address _address, bool _status) public;
  function burn(address _burner, uint256 _value) onlyOwner public;
}










