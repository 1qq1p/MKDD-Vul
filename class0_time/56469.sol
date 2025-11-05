pragma solidity ^0.4.24;





library SafeMath {
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

























pragma solidity >= 0.4.22 < 0.5;

contract BonusToken is ERC20, ERC20Detailed, Ownable {

    address public gameAddress;
    address public investTokenAddress;
    uint public maxLotteryParticipants;

    mapping (address => uint256) public ethLotteryBalances;
    address[] public ethLotteryParticipants;
    uint256 public ethLotteryBank;
    bool public isEthLottery;

    mapping (address => uint256) public tokensLotteryBalances;
    address[] public tokensLotteryParticipants;
    uint256 public tokensLotteryBank;
    bool public isTokensLottery;

    modifier onlyGame() {
        require(msg.sender == gameAddress);
        _;
    }

    modifier tokenIsAvailable {
        require(investTokenAddress != address(0));
        _;
    }

    constructor (address startGameAddress) public ERC20Detailed("Bet Token", "BET", 18) {
        setGameAddress(startGameAddress);
    }

    function setGameAddress(address newGameAddress) public onlyOwner {
        require(newGameAddress != address(0));
        gameAddress = newGameAddress;
    }

    function buyTokens(address buyer, uint256 tokensAmount) public onlyGame {
        _mint(buyer, tokensAmount * 10**18);
    }

    function startEthLottery() public onlyGame {
        isEthLottery = true;
    }

    function startTokensLottery() public onlyGame tokenIsAvailable {
        isTokensLottery = true;
    }

    function restartEthLottery() public onlyGame {
        for (uint i = 0; i < ethLotteryParticipants.length; i++) {
            ethLotteryBalances[ethLotteryParticipants[i]] = 0;
        }
        ethLotteryParticipants = new address[](0);
        ethLotteryBank = 0;
        isEthLottery = false;
    }

    function restartTokensLottery() public onlyGame tokenIsAvailable {
        for (uint i = 0; i < tokensLotteryParticipants.length; i++) {
            tokensLotteryBalances[tokensLotteryParticipants[i]] = 0;
        }
        tokensLotteryParticipants = new address[](0);
        tokensLotteryBank = 0;
        isTokensLottery = false;
    }

    function updateEthLotteryBank(uint256 value) public onlyGame {
        ethLotteryBank = ethLotteryBank.sub(value);
    }

    function updateTokensLotteryBank(uint256 value) public onlyGame {
        tokensLotteryBank = tokensLotteryBank.sub(value);
    }

    function swapTokens(address account, uint256 tokensToBurnAmount) public {
        require(msg.sender == investTokenAddress);
        _burn(account, tokensToBurnAmount);
    }

    function sendToEthLottery(uint256 value) public {
        require(!isEthLottery);
        require(ethLotteryParticipants.length < maxLotteryParticipants);
        address account = msg.sender;
        _burn(account, value);
        if (ethLotteryBalances[account] == 0) {
            ethLotteryParticipants.push(account);
        }
        ethLotteryBalances[account] = ethLotteryBalances[account].add(value);
        ethLotteryBank = ethLotteryBank.add(value);
    }

    function sendToTokensLottery(uint256 value) public tokenIsAvailable {
        require(!isTokensLottery);
        require(tokensLotteryParticipants.length < maxLotteryParticipants);
        address account = msg.sender;
        _burn(account, value);
        if (tokensLotteryBalances[account] == 0) {
            tokensLotteryParticipants.push(account);
        }
        tokensLotteryBalances[account] = tokensLotteryBalances[account].add(value);
        tokensLotteryBank = tokensLotteryBank.add(value);
    }

    function ethLotteryParticipants() public view returns(address[]) {
        return ethLotteryParticipants;
    }

    function tokensLotteryParticipants() public view returns(address[]) {
        return tokensLotteryParticipants;
    }

    function setInvestTokenAddress(address newInvestTokenAddress) external onlyOwner {
        require(newInvestTokenAddress != address(0));
        investTokenAddress = newInvestTokenAddress;
    }

    function setMaxLotteryParticipants(uint256 participants) external onlyOwner {
        maxLotteryParticipants = participants;
    }
}
