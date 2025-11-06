pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;






library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}





library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); 
    uint256 c = _a / _b;
    

    return c;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}





contract BancorSelectorProvider is SelectorProvider {
    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {
        if (genericSelector == getAmountToGive) {
            return bytes4(keccak256("getAmountToGive((address,address[11],address,uint256,uint256,uint256))"));
        } else if (genericSelector == staticExchangeChecks) {
            return bytes4(keccak256("staticExchangeChecks((address,address[11],address,uint256,uint256,uint256))"));
        } else if (genericSelector == performBuyOrder) {
            return bytes4(keccak256("performBuyOrder((address,address[11],address,uint256,uint256,uint256),uint256)"));
        } else if (genericSelector == performSellOrder) {
            return bytes4(keccak256("performSellOrder((address,address[11],address,uint256,uint256,uint256),uint256)"));
        } else {
            return bytes4(0x0);
        }
    }
}


