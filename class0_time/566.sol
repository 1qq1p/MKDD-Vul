pragma solidity ^0.4.11;





library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}






contract MintableToken is StandardToken, Ownable, Pausable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;
    uint256 public constant maxTokensToMint = 13600000 ether;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    





    function mint(address _to, uint256 _amount) whenNotPaused onlyOwner returns (bool) {
        return mintInternal(_to, _amount);
    }

    



    function finishMinting() whenNotPaused onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    function mintInternal(address _to, uint256 _amount) internal canMint returns (bool) {
        require(totalSupply.add(_amount) <= maxTokensToMint);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(this, _to, _amount);
        return true;
    }
}
