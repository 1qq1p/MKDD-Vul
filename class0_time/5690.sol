pragma solidity ^0.4.15;





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}






contract TokenController {
    
    
    
    function proxyPayment(address _owner) payable returns(bool);

    
    
    
    
    
    
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    
    
    
    
    
    
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}
