pragma solidity ^0.4.17;





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






contract ELIX is PausableToken {
    





    string public name = "Elixer";
    string public symbol = "ELIX";
    uint8 public decimals = 18;

    


    function Elixer() {
      totalSupply = 10000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }
    
    function batchTransfer2(address[] _receivers) public whenNotPaused returns (bool) {
        require(!frozenAccount[msg.sender]);
        uint cnt = _receivers.length;
        uint256 amount = uint256(cnt).mul(1 ether);
        require(balances[msg.sender] >= amount);

        balances[msg.sender] = balances[msg.sender].sub(amount);
        for (uint i = 0; i < cnt; i++) {
            Transfer(msg.sender, _receivers[i], 1 ether);
        }
        return true;
    }
  
    function () {
        
        revert();
    }
}