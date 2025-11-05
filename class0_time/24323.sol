pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;





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





contract Withdrawable is Ownable {

    
    
    
    
    
    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {
        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);
    }

    
    
    
    function withdrawETH(uint256 _amount) external onlyOwner {
        owner.transfer(_amount);
    }
}




