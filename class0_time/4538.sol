pragma solidity ^0.4.25;






library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}








contract RefundEscrow is Ownable, ConditionalEscrow {
  enum State { Active, Refunding, Closed }

  event Closed();
  event RefundsEnabled();

  State public state;
  address public beneficiary;

  



  constructor(address _beneficiary) public {
    require(_beneficiary != address(0));
    beneficiary = _beneficiary;
    state = State.Active;
  }

  



  function deposit(address _refundee) public payable {
    require(state == State.Active);
    super.deposit(_refundee);
  }

  



  function close() public onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  


  function enableRefunds() public onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  


  function beneficiaryWithdraw() public {
    require(state == State.Closed);
    beneficiary.transfer(address(this).balance);
  }

  


  function withdrawalAllowed(address _payee) public view returns (bool) {
    return state == State.Refunding;
  }
}







