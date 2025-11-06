pragma solidity 0.4.24;






library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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
}






contract LCGC_Token is BurnableToken, Owned {
    string public constant name = "Life Care Global Coin";
    string public constant symbol = "LCGC";
    uint8 public constant decimals = 18;
 
    
    uint256 public constant HARD_CAP = 3000000000 * 10**uint256(decimals);

    
    address public saleTokensAddress;

    
    TokenVault public reserveTokensVault;

    
    uint64 internal daySecond     = 86400;
    uint64 internal lock90Days    = 90;
    uint64 internal unlock100Days = 100;
    uint64 internal lock365Days   = 365;

    
    mapping(address => address) public vestingOf;

    constructor(address _saleTokensAddress) public payable {
        require(_saleTokensAddress != address(0));

        saleTokensAddress = _saleTokensAddress;

        
        uint256 saleTokens = 2000000000;
        createTokensInt(saleTokens, saleTokensAddress);

        require(totalSupply_ <= HARD_CAP);
    }

    
    function createReserveTokensVault() external onlyOwner {
        require(reserveTokensVault == address(0));

        
        uint256 reserveTokens = 1000000000;
        reserveTokensVault = createTokenVaultInt(reserveTokens);

        require(totalSupply_ <= HARD_CAP);
    }

    
    function createTokenVaultInt(uint256 tokens) internal onlyOwner returns (TokenVault) {
        TokenVault tokenVault = new TokenVault(ERC20(this));
        createTokensInt(tokens, tokenVault);
        tokenVault.fillUpAllowance();
        return tokenVault;
    }

    
    function createTokensInt(uint256 _tokens, address _destination) internal onlyOwner {
        uint256 tokens = _tokens * 10**uint256(decimals);
        totalSupply_ = totalSupply_.add(tokens);
        balances[_destination] = balances[_destination].add(tokens);
        emit Transfer(0x0, _destination, tokens);

        require(totalSupply_ <= HARD_CAP);
    }

    
    function vestTokensDetailInt(
                        address _beneficiary,
                        uint256 _startS,
                        uint256 _cliffS,
                        uint256 _durationS,
                        bool _revocable,
                        uint256 _tokensAmountInt) external onlyOwner {
        require(_beneficiary != address(0));

        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);

        if(vestingOf[_beneficiary] == 0x0) {
            TokenVesting vesting = new TokenVesting(_beneficiary, _startS, _cliffS, _durationS, _revocable, owner);
            vestingOf[_beneficiary] = address(vesting);
        }

        require(this.transferFrom(reserveTokensVault, vestingOf[_beneficiary], tokensAmount));
    }

    
    function vestTokensStartAtInt(
                            address _beneficiary, 
                            uint256 _tokensAmountInt,
                            uint256 _startS,
                            uint256 _afterDay,
                            uint256 _cliffDay,
                            uint256 _durationDay ) public onlyOwner {
        require(_beneficiary != address(0));

        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);
        uint256 afterSec = _afterDay * daySecond;
        uint256 cliffSec = _cliffDay * daySecond;
        uint256 durationSec = _durationDay * daySecond;

        if(vestingOf[_beneficiary] == 0x0) {
            TokenVesting vesting = new TokenVesting(_beneficiary, _startS + afterSec, cliffSec, durationSec, true, owner);
            vestingOf[_beneficiary] = address(vesting);
        }

        require(this.transferFrom(reserveTokensVault, vestingOf[_beneficiary], tokensAmount));
    }

    
    function vestTokensFromNowInt(address _beneficiary, uint256 _tokensAmountInt, uint256 _afterDay, uint256 _cliffDay, uint256 _durationDay ) public onlyOwner {
        vestTokensStartAtInt(_beneficiary, _tokensAmountInt, now, _afterDay, _cliffDay, _durationDay);
    }

    
    function vestCmdNow1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {
        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, 0, unlock100Days);
    }
    
    function vestCmd3Month1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {
        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, lock90Days, 0, unlock100Days);
    }

    
    function vestCmd1YearInstantInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {
        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, lock365Days, lock365Days);
    }

    
    function releaseVestedTokens() external {
        releaseVestedTokensFor(msg.sender);
    }

    
    
    function releaseVestedTokensFor(address _owner) public {
        TokenVesting(vestingOf[_owner]).release(this);
    }

    
    function lockedBalanceOf(address _owner) public view returns (uint256) {
        return balances[vestingOf[_owner]];
    }

    
    function releaseableBalanceOf(address _owner) public view returns (uint256) {
        if (vestingOf[_owner] == address(0) ) {
            return 0;
        } else {
            return TokenVesting(vestingOf[_owner]).releasableAmount(this);
        }
    }

    
    
    function revokeVestedTokensFor(address _owner) public onlyOwner {
        TokenVesting(vestingOf[_owner]).revoke(this);
    }

    
    function makeReserveToVault() external onlyOwner {
        require(reserveTokensVault != address(0));
        reserveTokensVault.fillUpAllowance();
    }

}