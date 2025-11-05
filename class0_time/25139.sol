






pragma solidity 0.4.25;


contract WalletController is RequiringAuthorization {
    address public destination;
    address public defaultSweeper = address(new DefaultSweeper(address(this)));
    bool public halted = false;

    mapping(address => address) public sweepers;
    mapping(address => bool) public wallets;

    event EthDeposit(address _from, address _to, uint _amount);
    event WalletCreated(address _address);
    event Sweeped(address _from, address _to, address _token, uint _amount);

    modifier onlyWallet {
        require(wallets[msg.sender]);
        _;
    }

    constructor(address _casino) public RequiringAuthorization(_casino) {
        owner = msg.sender;
        destination = msg.sender;
    }

    function setDestination(address _destination) public {
        destination = _destination;
    }

    function createWallet() public {
        address wallet = address(new UserWallet(this));
        wallets[wallet] = true;
        emit WalletCreated(wallet);
    }

    function createWallets(uint count) public {
        for (uint i = 0; i < count; i++) {
            createWallet();
        }
    }

    function addSweeper(address _token, address _sweeper) public onlyOwner {
        sweepers[_token] = _sweeper;
    }

    function halt() public onlyAuthorized {
        halted = true;
    }

    function start() public onlyOwner {
        halted = false;
    }

    function sweeperOf(address _token) public view returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == 0) sweeper = defaultSweeper;
        return sweeper;
    }

    function logEthDeposit(address _from, address _to, uint _amount) public onlyWallet {
        emit EthDeposit(_from, _to, _amount);
    }

    function logSweep(address _from, address _to, address _token, uint _amount) public {
        emit Sweeped(_from, _to, _token, _amount);
    }
}

