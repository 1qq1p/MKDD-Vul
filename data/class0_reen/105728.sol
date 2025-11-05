pragma solidity ^0.4.17;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract Skipday is ERC20Token, OpsManaged, SkipdayConfig {
    bool public finalized;
    event Burnt(address indexed _from, uint256 _amount);
    event Finalized();

    function Skipday() public ERC20Token(TOKEN_SYMBOL, TOKEN_NAME, TOKEN_DECIMALS, TOKENS_MAX) OpsManaged(){
        finalized = false;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);
        return super.transferFrom(_from, _to, _value);
    }

    function checkTransferAllowed(address _sender, address _to) private view {
        if (finalized) {
            return;
        }
        require(isOwnerOrOps(_sender) || _to == owner);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenTotalSupply = tokenTotalSupply.sub(_value);
        Burnt(msg.sender, _value);
        return true;
    }

    function finalize() external onlyAdmin returns (bool success) {
        require(!finalized);
        finalized = true;
        Finalized();
        return true;
    }
}