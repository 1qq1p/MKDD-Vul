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






contract MintableToken is StandardToken {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    address public mintAddress;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    modifier onlyMint() {
        require(msg.sender == mintAddress);
        _;
    }
    function setMintAddress(address addr) onlyOwner public {
        mintAddress = addr;
    }

    






    function mint(address _to, uint256 _amount) onlyMint canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}



