pragma solidity ^0.4.24;







contract DioToken is BasicToken, MintableToken {

    


    using SafeMath for uint256;

    string public constant name = "DIO Token";
    string public constant symbol = "DIO";
    uint8  public constant decimals = 8;

    


    uint constant E8 = 10**8;

    function transfer(
        address _to,
        uint256 _value
    )
    public
    onlyOwner
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
    onlyOwner
    returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    )
    public
    onlyOwner
    returns (bool)
    {
        return super.approve(_spender, _value);
    }

    function increaseApproval(
        address _spender,
        uint _addedValue
    )
    public
    onlyOwner
    returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
    public
    onlyOwner
    returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}