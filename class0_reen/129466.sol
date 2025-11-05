





pragma solidity 0.5.7;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Withdrawable is Ownable {
    event WithdrawEther(address indexed to, uint value);

    function withdrawEther(address payable _to, uint _value) onlyOwner public {
        require(_to != address(0));
        require(address(this).balance >= _value);

        address(_to).transfer(_value);

        emit WithdrawEther(_to, _value);
    }

    function withdrawTokensTransfer(IERC20 _token, address _to, uint256 _value) onlyOwner public {
        require(_token.transfer(_to, _value));
    }

    function withdrawTokensTransferFrom(IERC20 _token, address _from, address _to, uint256 _value) onlyOwner public {
        require(_token.transferFrom(_from, _to, _value));
    }

    function withdrawTokensApprove(IERC20 _token, address _spender, uint256 _value) onlyOwner public {
        require(_token.approve(_spender, _value));
    }
}
