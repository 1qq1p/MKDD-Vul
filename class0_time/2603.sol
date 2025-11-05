



 
 pragma solidity ^0.4.10;
















contract ITokenPool {    

    
    ERC20StandardToken public token;

    
    function setTrustee(address trustee, bool state);

    
    
    function getTokenAmount() constant returns (uint256 tokens) {tokens;}
}














