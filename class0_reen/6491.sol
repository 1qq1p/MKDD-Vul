pragma solidity ^0.4.18;








contract EcoPayments is Ownable, Pausable, HasNoEther, CanReclaimToken {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256[] private payoutDates = [
        1512086400, 
        1514764800, 
        1517443200, 
        1519862400, 
        1522540800, 
        1525132800, 
        1527811200, 
        1530403200, 
        1533081600, 
        1535760000, 
        1538352000, 
        1541030400  
    ];

    ERC20 public token;
    Vault public vault;

    mapping (address => uint256) private withdrawals;

    bool public initialized = false;

    modifier whenInitialized() {
        require (initialized == true);
        _;
    }

    function EcoPayments(ERC20 _token, Vault _vault) {
        token = _token;
        vault = _vault;
    }

    function init() onlyOwner returns (uint256) {
        require(token.balanceOf(this) == 5000000 * 10**18);
        initialized = true;
    }

    function withdraw() whenInitialized whenNotPaused public {
        uint256 amount = earningsOf(msg.sender);
        require (amount > 0);
        withdrawals[msg.sender] = withdrawals[msg.sender].add(amount);
        token.safeTransfer(msg.sender, amount);
    }

    function earningsOf(address _addr) public constant returns (uint256) {
        uint256 total = 0;
        uint256 interest = vault.contributionsOf(_addr).mul(833).div(10000);

        for (uint8 i = 0; i < payoutDates.length; i++) {
            if (now < payoutDates[i]) {
                break;
            }

            total = total.add(interest);
        }

        
        total = total.sub(withdrawals[_addr]);

        return total;
    }
}