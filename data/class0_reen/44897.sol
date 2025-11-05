
pragma solidity ^0.4.18;







contract UacCrowdsale is CrowdsaleBase {

    
    uint256 public constant START_TIME = 1525856400;                     
    uint256 public constant END_TIME = 1528448400;                       
    uint256 public constant PRESALE_VAULT_START = END_TIME + 7 days;
    uint256 public constant PRESALE_CAP = 17584778551358900100698693;
    uint256 public constant TOTAL_MAX_CAP = 15e6 * 1e18;                
    uint256 public constant CROWDSALE_CAP = 7.5e6 * 1e18;
    uint256 public constant FOUNDERS_CAP = 12e6 * 1e18;
    uint256 public constant UBIATARPLAY_CAP = 50.5e6 * 1e18;
    uint256 public constant ADVISORS_CAP = 4915221448641099899301307;

    
    uint256 public constant BONUS_TIER1 = 108;                           
    uint256 public constant BONUS_TIER2 = 106;                           
    uint256 public constant BONUS_TIER3 = 104;                           
    uint256 public constant BONUS_DURATION_1 = 3 hours;
    uint256 public constant BONUS_DURATION_2 = 12 hours;
    uint256 public constant BONUS_DURATION_3 = 42 hours;

    uint256 public constant FOUNDERS_VESTING_CLIFF = 1 years;
    uint256 public constant FOUNDERS_VESTING_DURATION = 2 years;

    Reservation public reservation;

    
    PresaleTokenVault public presaleTokenVault;
    TokenVesting public foundersVault;
    UbiatarPlayVault public ubiatarPlayVault;

    
    address public foundersWallet;
    address public advisorsWallet;
    address public ubiatarPlayWallet;

    address public wallet;

    UacToken public token;

    
    bool public didOwnerEndCrowdsale;

    








    function UacCrowdsale(
        address _token,
        address _reservation,
        address _presaleTokenVault,
        address _foundersWallet,
        address _advisorsWallet,
        address _ubiatarPlayWallet,
        address _wallet,
        address[] _kycSigners
    )
        public
        CrowdsaleBase(START_TIME, END_TIME, TOTAL_MAX_CAP, _wallet, _kycSigners)
    {
        token = UacToken(_token);
        reservation = Reservation(_reservation);
        presaleTokenVault = PresaleTokenVault(_presaleTokenVault);
        foundersWallet = _foundersWallet;
        advisorsWallet = _advisorsWallet;
        ubiatarPlayWallet = _ubiatarPlayWallet;
        wallet = _wallet;
        
        foundersVault = new TokenVesting(foundersWallet, END_TIME, FOUNDERS_VESTING_CLIFF, FOUNDERS_VESTING_DURATION, false);

        
        ubiatarPlayVault = new UbiatarPlayVault(ubiatarPlayWallet, address(token), END_TIME);
    }

    function mintPreAllocatedTokens() public onlyOwner {
        mintTokens(address(foundersVault), FOUNDERS_CAP);
        mintTokens(advisorsWallet, ADVISORS_CAP);
        mintTokens(address(ubiatarPlayVault), UBIATARPLAY_CAP);
    }

    




    function initPresaleTokenVault(address[] beneficiaries, uint256[] balances) public onlyOwner {
        require(beneficiaries.length == balances.length);

        presaleTokenVault.init(beneficiaries, balances, PRESALE_VAULT_START, token);

        uint256 totalPresaleBalance = 0;
        uint256 balancesLength = balances.length;
        for(uint256 i = 0; i < balancesLength; i++) {
            totalPresaleBalance = totalPresaleBalance.add(balances[i]);
        }

        mintTokens(presaleTokenVault, totalPresaleBalance);
    }

    




    function price() public view returns (uint256 _price) {
        if (block.timestamp <= start.add(BONUS_DURATION_1)) {
            return tokenPerEth.mul(BONUS_TIER1).div(1e2);
        } else if (block.timestamp <= start.add(BONUS_DURATION_2)) {
            return tokenPerEth.mul(BONUS_TIER2).div(1e2);
        } else if (block.timestamp <= start.add(BONUS_DURATION_3)) {
            return tokenPerEth.mul(BONUS_TIER3).div(1e2);
        }
        return tokenPerEth;
    }

    






    function mintReservationTokens(address to, uint256 amount) public {
        require(msg.sender == address(reservation));
        tokensSold = tokensSold.add(amount);
        availableTokens = availableTokens.sub(amount);
        mintTokens(to, amount);
    }

    





    function mintTokens(address to, uint256 amount) private {
        token.mint(to, amount);
    }

    


    function closeCrowdsale() public onlyOwner {
        require(block.timestamp >= START_TIME && block.timestamp < END_TIME);
        didOwnerEndCrowdsale = true;
    }

    


    function finalise() public onlyOwner {
        require(didOwnerEndCrowdsale || block.timestamp > end || capReached);
        token.finishMinting();
        token.unpause();

        
        
        
        token.transferOwnership(owner);
    }
}









pragma solidity ^0.4.19;



