pragma solidity ^0.4.24;




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

contract Airdropper2 is Ownable {
    using SafeMath for uint256;
    function multisend(address[] wallets, uint256[] values) external onlyTeam returns (uint256) {
        
        uint256 limit = globalLimit;
        uint256 tokensToIssue = 0;
        address wallet = address(0);
        
        for (uint i = 0; i < wallets.length; i++) {

            tokensToIssue = values[i];
            wallet = wallets[i];

           if(tokensToIssue > 0 && wallet != address(0)) { 
               
                if(personalLimit[wallet] > globalLimit) {
                    limit = personalLimit[wallet];
                }

                if(distributedBalances[wallet].add(tokensToIssue) > limit) {
                    tokensToIssue = limit.sub(distributedBalances[wallet]);
                }

                if(limit > distributedBalances[wallet]) {
                    distributedBalances[wallet] = distributedBalances[wallet].add(tokensToIssue);
                    ERC20(token).transfer(wallet, tokensToIssue);
                }
           }
        }
    }
    
    function simplesend(address[] wallets) external onlyTeam returns (uint256) {
        
        uint256 tokensToIssue = globalLimit;
        address wallet = address(0);
        
        for (uint i = 0; i < wallets.length; i++) {
            
            wallet = wallets[i];
           if(wallet != address(0)) {
               
                if(distributedBalances[wallet] == 0) {
                    distributedBalances[wallet] = distributedBalances[wallet].add(tokensToIssue);
                    ERC20(token).transfer(wallet, tokensToIssue);
                }
           }
        }
    }


    function evacuateTokens(ERC20 _tokenInstance, uint256 _tokens) external onlyOwner returns (bool success) {
        _tokenInstance.transfer(owner, _tokens);
        return true;
    }

    function _evacuateEther() onlyOwner external {
        owner.transfer(address(this).balance);
    }
}