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








contract DelegateERC20 {
    function delegateTotalSupply() public view returns (uint256);

    function delegateBalanceOf(address who) public view returns (uint256);

    function delegateTransfer(address to, uint256 value, address origSender) public returns (bool);

    function delegateAllowance(address owner, address spender) public view returns (uint256);

    function delegateTransferFrom(address from, address to, uint256 value, address origSender) public returns (bool);

    function delegateApprove(address spender, uint256 value, address origSender) public returns (bool);

    function delegateIncreaseApproval(address spender, uint addedValue, address origSender) public returns (bool);

    function delegateDecreaseApproval(address spender, uint subtractedValue, address origSender) public returns (bool);
}


