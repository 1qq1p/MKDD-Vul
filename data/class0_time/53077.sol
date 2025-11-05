pragma solidity ^0.4.15;
contract Token is ERC20 {
    using SafeMath for uint;
    string public name = "Patron coin";
    string public symbol = "PAT";
    uint8 public decimals = 18;
    address public crowdsaleMinter;
    modifier onlyCrowdsaleMinter(){
        require(msg.sender == crowdsaleMinter);
        _;
    }
    modifier isNotStartedOnly() {
        require(!isStarted);
        _;
    }
    function Token(address _crowdsaleMinter){
        crowdsaleMinter = _crowdsaleMinter;
    }
    function start()
    public
    onlyCrowdsaleMinter
    isNotStartedOnly
    {
        isStarted = true;
    }
    function emergencyStop()
    public
    only(owner)
    {
        isStarted = false;
    }
    
    function mint(address _to, uint _amount) public
    onlyCrowdsaleMinter
    isNotStartedOnly
    returns(bool)
    {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        return true;
    }

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value, address _address)
    onlyCrowdsaleMinter
    returns (bool)
    {
        require(_value <= balances[_address]);

        balances[_address] = balances[_address].sub(_value);
        totalSupply = totalSupply.sub(_value);

        Burn(_address, _value);

        return true;
    }

}