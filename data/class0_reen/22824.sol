



































pragma solidity 0.4.25;






contract ExternStateToken is SelfDestructible, Proxyable, TokenFallbackCaller {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    

    
    TokenState public tokenState;

    
    string public name;
    string public symbol;
    uint public totalSupply;
    uint8 public decimals;

    








    constructor(address _proxy, TokenState _tokenState,
                string _name, string _symbol, uint _totalSupply,
                uint8 _decimals, address _owner)
        SelfDestructible(_owner)
        Proxyable(_proxy, _owner)
        public
    {
        tokenState = _tokenState;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }

    

    




    function allowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return tokenState.allowance(owner, spender);
    }

    


    function balanceOf(address account)
        public
        view
        returns (uint)
    {
        return tokenState.balanceOf(account);
    }

    

    



 
    function setTokenState(TokenState _tokenState)
        external
        optionalProxy_onlyOwner
    {
        tokenState = _tokenState;
        emitTokenStateUpdated(_tokenState);
    }

    function _internalTransfer(address from, address to, uint value, bytes data) 
        internal
        returns (bool)
    { 
        
        require(to != address(0), "Cannot transfer to the 0 address");
        require(to != address(this), "Cannot transfer to the underlying contract");
        require(to != address(proxy), "Cannot transfer to the proxy contract");

        
        tokenState.setBalanceOf(from, tokenState.balanceOf(from).sub(value));
        tokenState.setBalanceOf(to, tokenState.balanceOf(to).add(value));

        
        
        
        callTokenFallbackIfNeeded(from, to, value, data);
        
        
        emitTransfer(from, to, value);

        return true;
    }

    



    function _transfer_byProxy(address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {
        return _internalTransfer(from, to, value, data);
    }

    



    function _transferFrom_byProxy(address sender, address from, address to, uint value, bytes data)
        internal
        returns (bool)
    {
        
        tokenState.setAllowance(from, sender, tokenState.allowance(from, sender).sub(value));
        return _internalTransfer(from, to, value, data);
    }

    


    function approve(address spender, uint value)
        public
        optionalProxy
        returns (bool)
    {
        address sender = messageSender;

        tokenState.setAllowance(sender, spender, value);
        emitApproval(sender, spender, value);
        return true;
    }

    

    event Transfer(address indexed from, address indexed to, uint value);
    bytes32 constant TRANSFER_SIG = keccak256("Transfer(address,address,uint256)");
    function emitTransfer(address from, address to, uint value) internal {
        proxy._emit(abi.encode(value), 3, TRANSFER_SIG, bytes32(from), bytes32(to), 0);
    }

    event Approval(address indexed owner, address indexed spender, uint value);
    bytes32 constant APPROVAL_SIG = keccak256("Approval(address,address,uint256)");
    function emitApproval(address owner, address spender, uint value) internal {
        proxy._emit(abi.encode(value), 3, APPROVAL_SIG, bytes32(owner), bytes32(spender), 0);
    }

    event TokenStateUpdated(address newTokenState);
    bytes32 constant TOKENSTATEUPDATED_SIG = keccak256("TokenStateUpdated(address)");
    function emitTokenStateUpdated(address newTokenState) internal {
        proxy._emit(abi.encode(newTokenState), 1, TOKENSTATEUPDATED_SIG, 0, 0, 0);
    }
}






































