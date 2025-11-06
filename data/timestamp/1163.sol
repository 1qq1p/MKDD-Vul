pragma solidity ^0.4.23;








contract MigrationAgent is Ownable {
    using SafeMath for uint256;

    ERC20 public legacySycContract;    
    ERC20 public sycContract;       
    uint256 public targetSupply;    
    uint256 public migratedSupply;  

    mapping (address => bool) public migrated;  

    uint256 public timelockReleaseTime; 
    TokenTimelock public tokenTimelock; 

    event Migrate(address indexed holder, uint256 balance);

    function MigrationAgent(address _legacySycAddress, address _sycAddress, uint256 _timelockReleaseTime) public {
        require(_legacySycAddress != address(0));
        require(_sycAddress != address(0));

        legacySycContract = ERC20(_legacySycAddress);
        targetSupply = legacySycContract.totalSupply();
        timelockReleaseTime = _timelockReleaseTime;
        sycContract = ERC20(_sycAddress);
    }

    



    function migrateVault(address _legacyVaultAddress) onlyOwner external { 
        require(_legacyVaultAddress != address(0));
        require(!migrated[_legacyVaultAddress]);
        require(tokenTimelock == address(0));

        
        migrated[_legacyVaultAddress] = true;        
        uint256 timelockAmount = legacySycContract.balanceOf(_legacyVaultAddress);
        tokenTimelock = new TokenTimelock(sycContract, msg.sender, timelockReleaseTime);
        sycContract.transfer(tokenTimelock, timelockAmount);
        migratedSupply = migratedSupply.add(timelockAmount);
        emit Migrate(_legacyVaultAddress, timelockAmount);
    }

    




    function migrateBalances(address[] _tokenHolders) onlyOwner external {
        for (uint256 i = 0; i < _tokenHolders.length; i++) {
            migrateBalance(_tokenHolders[i]);
        }
    }

    




    function migrateBalance(address _tokenHolder) onlyOwner public returns (bool) {
        if (migrated[_tokenHolder]) {
            return false;   
        }

        uint256 balance = legacySycContract.balanceOf(_tokenHolder);
        if (balance == 0) {
            return false;   
        }

        
        migrated[_tokenHolder] = true;
        sycContract.transfer(_tokenHolder, balance);
        migratedSupply = migratedSupply.add(balance);
        emit Migrate(_tokenHolder, balance);
        return true;
    }

    


    function kill() onlyOwner public {
        uint256 balance = sycContract.balanceOf(this);
        sycContract.transfer(owner, balance);
        selfdestruct(owner);
    }
}