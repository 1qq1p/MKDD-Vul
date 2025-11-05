pragma solidity ^0.4.18;























library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract GasFaucet is Owned {
    using SafeMath for uint256;

    address public faucetTokenAddress;
    uint256 public priceInWeiPerSatoshi;

    event Dispense(address indexed destination, uint256 sendAmount);

    constructor() public {
        
        
        
        faucetTokenAddress = 0xB6eD7644C69416d67B522e20bC294A9a9B405B31;

        
        
        priceInWeiPerSatoshi = 0;
    }

    
    
    
    
    
    
    function dispense(address destination) public {
        uint256 sendAmount = calculateDispensedTokensForGasPrice(tx.gasprice);
        require(tokenBalance() > sendAmount);

        ERC20Interface(faucetTokenAddress).transfer(destination, sendAmount);

        emit Dispense(destination, sendAmount);
    }
    
    
    
    
    function calculateDispensedTokensForGasPrice(uint256 gasprice) public view returns (uint256) {
        if(priceInWeiPerSatoshi == 0){ 
            return 0; 
        }
        return gasprice.div(priceInWeiPerSatoshi);
    }
    
    
    
    
    function tokenBalance() public view returns (uint)  {
        return ERC20Interface(faucetTokenAddress).balanceOf(this);
    }
    
    
    
    
    function getWeiPerSatoshi() public view returns (uint256) {
        return priceInWeiPerSatoshi;
    }
    
    
    
    
    function setWeiPerSatoshi(uint256 price) public onlyOwner {
        priceInWeiPerSatoshi = price;
    }

    
    
    
    function () public payable {
        revert();
    }

    
    
    
    function withdrawEth(uint256 amount) public onlyOwner {
        require(amount < address(this).balance);
        owner.transfer(amount);
    }

    
    
    
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner {
        
        
        
        
        
        
        
        

        ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}