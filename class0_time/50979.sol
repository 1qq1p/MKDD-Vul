pragma solidity ^0.4.19;






contract PausableToken is StandardToken, Pausable {
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
        return super.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) public whenNotPaused returns(bool) {
        return super.approve(_spender, _value);
    }
    
    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns(bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns(bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}







library SafeERC20 {
    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
        assert(token.transfer(to, value));
    }
    
    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
        assert(token.transferFrom(from, to, value));
    }
    
    function safeApprove(ERC20 token, address spender, uint256 value) internal {
        assert(token.approve(spender, value));
    }
}





