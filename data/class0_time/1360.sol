pragma solidity ^0.4.24;





contract AlethenaShares is ERC20, Claimable {

    string public constant name = "Alethena Equity";
    string public constant symbol = "ALEQ";
    uint8 public constant decimals = 0; 

    using SafeMath for uint256;

      
    string public constant termsAndConditions = "shares.alethena.com";

    mapping(address => uint256) balances;
    uint256 totalSupply_;        
    uint256 totalShares_ = 1397188; 

    event Mint(address indexed shareholder, uint256 amount, string message);
    event Unmint(uint256 amount, string message);

  
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

  


    function totalShares() public view returns (uint256) {
        return totalShares_;
    }

    function setTotalShares(uint256 _newTotalShares) public onlyOwner() {
        require(_newTotalShares >= totalSupply());
        totalShares_ = _newTotalShares;
    }

  
    function mint(address shareholder, uint256 _amount, string _message) public onlyOwner() {
        require(_amount > 0);
        require(totalSupply_.add(_amount) <= totalShares_);
        balances[shareholder] = balances[shareholder].add(_amount);
        totalSupply_ = totalSupply_ + _amount;
        emit Mint(shareholder, _amount, _message);
    }









    function unmint(uint256 _amount, string _message) public onlyOwner() {
        require(_amount > 0);
        require(_amount <= balanceOf(owner));
        balances[owner] = balances[owner].sub(_amount);
        totalSupply_ = totalSupply_ - _amount;
        emit Unmint(_amount, _message);
    }

  
    bool public isPaused = false;

  




    function pause(bool _pause, string _message, address _newAddress, uint256 _fromBlock) public onlyOwner() {
        isPaused = _pause;
        emit Pause(_pause, _message, _newAddress, _fromBlock);
    }

    event Pause(bool paused, string message, address newAddress, uint256 fromBlock);








  




    function transfer(address _to, uint256 _value) public returns (bool) {
        clearClaim();
        internalTransfer(msg.sender, _to, _value);
        return true;
    }

    function internalTransfer(address _from, address _to, uint256 _value) internal {
        require(!isPaused);
        require(_to != address(0));
        require(_value <= balances[_from]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

  




    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    mapping (address => mapping (address => uint256)) internal allowed;

  





    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        internalTransfer(_from, _to, _value);
        return true;
    }

  








    function approve(address _spender, uint256 _value) public returns (bool) {
        require(!isPaused);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    event Approval(address approver, address spender, uint256 value);
  





    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

  








    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        require(!isPaused);
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

  








    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        require(!isPaused);
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

library SafeMath {

  


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        
        
        
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

  


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

  


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}