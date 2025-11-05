pragma solidity ^0.4.25;

contract PauseBurnableERC827Token is ERC827Token, Ownable {
    using SafeMath for uint256;
    event Pause();
    event Unpause();
    event PauseOperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event Burn(address indexed burner, uint256 value);

    bool public paused = false;
    address public pauseOperator;
    


    modifier onlyPauseOperator() {
        require(msg.sender == pauseOperator || msg.sender == owner);
        _;
    }
    


    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    


    modifier whenPaused() {
        require(paused);
        _;
    }
    



    constructor() public {
        pauseOperator = msg.sender;
    }
    


    function transferPauseOperator(address newPauseOperator) onlyPauseOperator public {
        require(newPauseOperator != address(0));
        emit PauseOperatorTransferred(pauseOperator, newPauseOperator);
        pauseOperator = newPauseOperator;
    }
    


    function pause() onlyPauseOperator whenNotPaused public {
        paused = true;
        emit Pause();
    }
    


    function unpause() onlyPauseOperator whenPaused public {
        paused = false;
        emit Unpause();
    }

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
    



    function burn(uint256 _value) public whenNotPaused {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        
        
        balances[_who] = balances[_who].sub(_value);
        
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    




    function burnFrom(address _from, uint256 _value) public whenNotPaused {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }
}
