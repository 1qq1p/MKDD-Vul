pragma solidity ^0.4.24;







contract BalanceSheet is ClaimableEx {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;

  AddressSet private holderSet;

  constructor() public {
    holderSet = new AddressSet();
  }

  




  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function addBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = balances[_addr].add(_value);

    _checkHolderSet(_addr);
  }

  function subBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = balances[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = _value;

    _checkHolderSet(_addr);
  }

  function setBalanceBatch(
    address[] _addrs,
    uint256[] _values
  )
    public
    onlyOwner
  {
    uint256 _count = _addrs.length;
    require(_count == _values.length);

    for(uint256 _i = 0; _i < _count; _i++) {
      setBalance(_addrs[_i], _values[_i]);
    }
  }

  function getTheNumberOfHolders() public view returns (uint256) {
    return holderSet.getTheNumberOfElements();
  }

  function getHolder(uint256 _index) public view returns (address) {
    return holderSet.elementAt(_index);
  }

  function _checkHolderSet(address _addr) internal {
    if (!holderSet.contains(_addr)) {
      holderSet.add(_addr);
    }
  }
}











