pragma solidity ^0.4.23;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}






contract Consumer is Ownable {

    address public hookableTokenAddress;

    modifier onlyHookableTokenAddress {
        require(msg.sender == hookableTokenAddress);
        _;
    }

    function setHookableTokenAddress(address _hookableTokenAddress) onlyOwner {
        hookableTokenAddress = _hookableTokenAddress;
    }

    function onMint(address _sender, address _to, uint256 _amount) onlyHookableTokenAddress {
    }

    function onBurn(address _sender, uint256 _value) onlyHookableTokenAddress {
    }

    function onTransfer(address _sender, address _to, uint256 _value) onlyHookableTokenAddress {
    }

    function onTransferFrom(address _sender, address _from, address _to, uint256 _value) onlyHookableTokenAddress {
    }

    function onApprove(address _sender, address _spender, uint256 _value) onlyHookableTokenAddress {
    }

    function onIncreaseApproval(address _sender, address _spender, uint _addedValue) onlyHookableTokenAddress {
    }

    function onDecreaseApproval(address _sender, address _spender, uint _subtractedValue) onlyHookableTokenAddress {
    }

    function onTaxTransfer(address _from, uint _tokensAmount) onlyHookableTokenAddress {
    }
}
