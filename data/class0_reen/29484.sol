pragma solidity 0.4.25;


contract IERC677Allowance is IERC20Allowance {

    
    
    

    
    
    
    
    
    
    
    function approveAndCall(address spender, uint256 amount, bytes extraData)
        public
        returns (bool success);

}
