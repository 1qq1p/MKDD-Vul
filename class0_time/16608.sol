pragma solidity ^0.4.24;








contract BondToken is StandardToken, Ownable, Pausable {
    using SafeMath for SafeMath;

    string public constant name = "19BIX6M01";
    string public constant symbol = "BIX1901";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 4030 * (10 ** uint256(decimals));

    


    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    








    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
    public
    returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function setOwner(
        address newOwner
    )
    public
    onlyOwner
    {
        _transferOwnership(newOwner);
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
}