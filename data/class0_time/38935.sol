pragma solidity ^0.4.18;








contract CoinsdomCoin is MintableToken, Pausable {
    using SafeMath for uint256;
    string public name = 'Coinsdom';
    string public symbol = 'CSD';
    uint256 public decimals = 18;
    mapping (address => bool) public tokenFallbackWhiteList;

    



    function CoinsdomCoin(
        uint256 _initialSupply
    )
        public
    {
        totalSupply_ = _initialSupply;
        balances[owner] = totalSupply_;
        emit Transfer(0x0, owner, totalSupply_);
    }

    


    function transfer(
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    


    function approve(
        address _spender,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    


    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    


    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    



    function _isContract(
        address _address
    )
        internal
        constant
        returns (bool)
    {
        uint256 length;
        assembly {
            length := extcodesize(_address)
        }
        return (length > 0);
    }

    



    function addContractToTokenFallbackWhiteList(
        address _address
    )
        onlyOwner
        public
    {
        require(_isContract(_address));
        tokenFallbackWhiteList[_address] = true;
    }

    



    function removeContractFromTokenFallbackWhiteList(
        address _address
    )
        onlyOwner
        public
    {
        require(_isContract(_address));
        delete tokenFallbackWhiteList[_address];
    }

    function transferAndCall(
        address _receiver,
        uint _amount,
        bytes _data)
        public
        returns (bool _success)
    {
        require(_isContract(_receiver));
        require(tokenFallbackWhiteList[_receiver]);
        transfer(_receiver, _amount);
        TokenFallback(_receiver).tokenFallback(msg.sender, _amount, _data);
        return true;
    }
}