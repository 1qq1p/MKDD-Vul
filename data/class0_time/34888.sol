






pragma solidity 0.5.2;

interface ERC20CompatibleToken {
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer (address to, uint tokens) external returns (bool success);
    function transferFrom (address from, address to, uint tokens) external returns (bool success);
}




library SafeMath {

    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    function div (uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub (uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c;
    }

}






contract RecurringBillingContractFactory {

    event NewRecurringBillingContractCreated(address token, address recurringBillingContract);

    function newRecurringBillingContract (address tokenAddress) public returns (address recurringBillingContractAddress) {
        TokenRecurringBilling rb = new TokenRecurringBilling(tokenAddress);
        emit NewRecurringBillingContractCreated(tokenAddress, address(rb));
        return address(rb);
    }

}
 		   	  				  	  	      		 			  		 	  	 		 	 		 		 	  	 			 	   		    	  	 			  			 	   		 	 		








































