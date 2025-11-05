pragma solidity 0.4.21;

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

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract realimmocoin is StandardToken {

    string public constant name = "real-immocoin";
    string public constant symbol = "RIC";
    uint8 public constant decimals =18;
    uint256 public constant INITIAL_SUPPLY = 1 * 10**9 * (10**uint256(decimals));
    uint256 public weiRaised;
    uint256 public tokenAllocated;
    address public owner;
    bool public saleToken = true;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);
    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function realimmocoin(address _owner) public {
        totalSupply = INITIAL_SUPPLY;
        owner = _owner;
        
        balances[owner] = INITIAL_SUPPLY;
        tokenAllocated = 0;
        transfersEnabled = true;
    }

    
    function() payable public {
        buyTokens(msg.sender);
    }

    function buyTokens(address _investor) public payable returns (uint256){
        require(_investor != address(0));
        require(saleToken == true);
        address wallet = owner;
        uint256 weiAmount = msg.value;
        uint256 tokens = validPurchaseTokens(weiAmount);
        if (tokens == 0) {revert();}
        weiRaised = weiRaised.add(weiAmount);
        tokenAllocated = tokenAllocated.add(tokens);
        mint(_investor, tokens, owner);

        emit TokenPurchase(_investor, weiAmount, tokens);
        wallet.transfer(weiAmount);
        return tokens;
    }

    function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
        uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
        if (addTokens > balances[owner]) {
            emit TokenLimitReached(tokenAllocated, addTokens);
            return 0;
        }
        return addTokens;
    }

    







    function getTotalAmountOfTokens(uint256 _weiAmount) internal pure returns (uint256) {
        uint256 amountOfTokens = 0;
        if(_weiAmount == 0){
            amountOfTokens = 5700 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.001 ether){
            amountOfTokens = 3 * 10**1 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.005 ether){
            amountOfTokens = 15 * 10**1 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.01 ether){
            amountOfTokens = 3 * 10**2 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.05 ether){
            amountOfTokens = 15 * 10**2 * (10**uint256(decimals));
        }
        if( _weiAmount == 0.1 ether){
            amountOfTokens = 3 * 10**3 * (10**uint256(decimals));
        }
        return amountOfTokens;
    }

    function mint(address _to, uint256 _amount, address _owner) internal returns (bool) {
        require(_to != address(0));
        require(_amount <= balances[_owner]);

        balances[_to] = balances[_to].add(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        emit Transfer(_owner, _to, _amount);
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner public returns (bool){
        require(_newOwner != address(0));
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function startSale() public onlyOwner {
        saleToken = true;
    }

    function stopSale() public onlyOwner {
        saleToken = false;
    }

    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }

    



    function claimTokens() public onlyOwner {
        owner.transfer(address(this).balance);
        uint256 balance = balanceOf(this);
        transfer(owner, balance);
        emit Transfer(this, owner, balance);
    }
}