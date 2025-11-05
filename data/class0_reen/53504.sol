pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 result = a * b;
        assert(a == 0 || result / a == b);
        return result;
    }
 
    function div(uint256 a, uint256 b)internal pure returns (uint256) {
        uint256 result = a / b;
        return result;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a); 
        return a - b; 
    } 
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) { 
        uint256 result = a + b; 
        assert(result >= a);
        return result;
    }
 
}

contract CryptosoulToken is MultisendableToken {
    
    event AllowMinting();
    event Burn(address indexed _from, uint256 _value);
    event Mint(address indexed _to, uint256 _value);
    
    string constant public name = "CryptoSoul";
    string constant public symbol = "SOUL";
    uint constant public decimals = 18;
    
    uint256 constant public START_TOKENS = 500000000 * 10**decimals; 
    uint256 constant public MINT_AMOUNT = 1370000 * 10**decimals;
    uint256 constant public MINT_INTERVAL = 1 days; 
    uint256 constant private MAX_BALANCE_VALUE = 10000000000 * 10**decimals;
    
    uint256 public nextMintPossibleDate = 0;
    bool public canMint = false;
    
    constructor() public {
        wallets[owner].tokensAmount = START_TOKENS;
        wallets[owner].canFreezeTokens = true;
        totalSupply = START_TOKENS;
        nextMintPossibleDate = 1538352000; 
        emit Mint(owner, START_TOKENS);
    }

    function allowMinting() public onlyOwner {
        
        require(!canMint
        && now >= nextMintPossibleDate);
        nextMintPossibleDate = now;
        canMint = true;
        emit AllowMinting();
    }

    function mint() public onlyOwner returns(bool) {
        require(canMint
        && now >= nextMintPossibleDate
        && totalSupply + MINT_AMOUNT <= MAX_BALANCE_VALUE);
        nextMintPossibleDate = nextMintPossibleDate.add(MINT_INTERVAL);
        wallets[owner].tokensAmount = wallets[owner].tokensAmount.
                                             add(MINT_AMOUNT);  
        totalSupply = totalSupply.add(MINT_AMOUNT);
        emit Mint(owner, MINT_AMOUNT);
        return true;
    }

    function burn(uint256 value) public onlyOwner returns(bool) {
        require(checkIfCanUseTokens(owner, value)
        && wallets[owner].tokensAmount >= value);
        wallets[owner].tokensAmount = wallets[owner].
                                             tokensAmount.sub(value);
        totalSupply = totalSupply.sub(value);                             
        emit Burn(owner, value);
        return true;
    }
    
    function transferOwnership(address _newOwner) public notSender(_newOwner) returns(bool) {
        require(msg.sender == masterKey 
        && _newOwner != address(0));
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
    
    function() public payable {
        revert();
    }
}