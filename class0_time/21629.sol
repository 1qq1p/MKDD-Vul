pragma solidity 0.4.25;

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

contract ERC677Token is ERC677, ERC20Token {
    function transferAndCall(address _receiver, uint _amount, bytes _data) public {
        require(super.transfer(_receiver, _amount));

        emit Transfer(msg.sender, _receiver, _amount, _data);

        
        if (isContract(_receiver)) {
            ERC677Receiver to = ERC677Receiver(_receiver);
            to.tokenFallback(msg.sender, _amount, _data);
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint len;
        assembly {
            len := extcodesize(_addr)
        }
        return len > 0;
    }
}
