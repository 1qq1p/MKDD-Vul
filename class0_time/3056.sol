pragma solidity 0.4.24;
pragma experimental "v0.5.0";

























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








contract OnlyMargin {

    

    
    address public DYDX_MARGIN;

    

    constructor(
        address margin
    )
        public
    {
        DYDX_MARGIN = margin;
    }

    

    modifier onlyMargin()
    {
        require(
            msg.sender == DYDX_MARGIN,
            "OnlyMargin#onlyMargin: Only Margin can call"
        );

        _;
    }
}










interface PositionCustodian {

    






    function getPositionDeedHolder(
        bytes32 positionId
    )
        external
        view
        returns (address);
}









library MarginHelper {
    function getPosition(
        address DYDX_MARGIN,
        bytes32 positionId
    )
        internal
        view
        returns (MarginCommon.Position memory)
    {
        (
            address[4] memory addresses,
            uint256[2] memory values256,
            uint32[6]  memory values32
        ) = Margin(DYDX_MARGIN).getPosition(positionId);

        return MarginCommon.Position({
            owedToken: addresses[0],
            heldToken: addresses[1],
            lender: addresses[2],
            owner: addresses[3],
            principal: values256[0],
            requiredDeposit: values256[1],
            callTimeLimit: values32[0],
            startTimestamp: values32[1],
            callTimestamp: values32[2],
            maxDuration: values32[3],
            interestRate: values32[4],
            interestPeriod: values32[5]
        });
    }
}








