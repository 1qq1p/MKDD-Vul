pragma solidity ^0.4.24;






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








contract Withdrawal is Ownable {
    
    address public withdrawWallet;

    



    event WithdrawLog(uint256 value);

    


    constructor(address _withdrawWallet) public {
        require(_withdrawWallet != address(0), "Invalid funds holder wallet.");

        withdrawWallet = _withdrawWallet;
    }

    


    function withdrawAll() external onlyOwner {
        uint256 weiAmount = address(this).balance;
      
        withdrawWallet.transfer(weiAmount);
        emit WithdrawLog(weiAmount);
    }

    



    function withdraw(uint256 _weiAmount) external onlyOwner {
        require(_weiAmount <= address(this).balance, "Not enough funds.");

        withdrawWallet.transfer(_weiAmount);
        emit WithdrawLog(_weiAmount);
    }
}







