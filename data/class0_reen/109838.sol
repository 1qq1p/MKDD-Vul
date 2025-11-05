pragma solidity 0.4.15;



contract MultiownedControlled is multiowned {

    event ControllerSet(address controller);
    event ControllerRetired(address was);


    modifier onlyController {
        require(msg.sender == m_controller);
        _;
    }


    

    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)
        multiowned(_owners, _signaturesRequired)
    {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    
    function detachController() external onlyController {
        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }


    

    
    address public m_controller;
}





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






