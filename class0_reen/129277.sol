pragma solidity ^0.4.24;







library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); 
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}







interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}









library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    )
    internal
    {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    )
    internal
    {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal
    {
        
        
        
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    )
    internal
    {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}









contract RefundEscrow is ConditionalEscrow {
    enum State { Active, Refunding, Closed }

    event RefundsClosed();
    event RefundsEnabled();

    State private _state;
    address private _beneficiary;

    



    constructor(address beneficiary) public {
        require(beneficiary != address(0));
        _beneficiary = beneficiary;
        _state = State.Active;
    }

    


    function state() public view returns (State) {
        return _state;
    }

    


    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    



    function deposit(address refundee) public payable {
        require(_state == State.Active);
        super.deposit(refundee);
    }

    



    function close() public onlyPrimary {
        require(_state == State.Active);
        _state = State.Closed;
        emit RefundsClosed();
    }

    


    function enableRefunds() public onlyPrimary {
        require(_state == State.Active);
        _state = State.Refunding;
        emit RefundsEnabled();
    }

    


    function beneficiaryWithdraw() public {
        require(_state == State.Closed);
        _beneficiary.transfer(address(this).balance);
    }

    


    function withdrawalAllowed(address payee) public view returns (bool) {
        return _state == State.Refunding;
    }
}




















