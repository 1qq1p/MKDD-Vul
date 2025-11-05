pragma solidity ^0.4.21;








contract BaldcoinCore is Ownable, StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint64 public cap;
    uint64 public promo;

    uint16 public cut;
    uint256 public minBet;

    mapping (string => bool) memeList;
    uint256 public countingMeme;

    address[] private users;

    event CountUp( address indexed from, uint256 count );
    event NewMeme( address indexed from, string meme );

    function BaldcoinCore(string _name, string _symbol, uint8 _decimals, uint64 _cap, uint64 _promo, uint16 _cut, uint256 _minBet, address[] _users) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        cap = _cap;
        promo = _promo;

        cut = _cut;
        minBet = _minBet;

        users = _users;

        countingMeme = 0;

        totalSupply_ = _cap;
        uint256 _availableSupply = _cap - _promo;

        balances[msg.sender] = _availableSupply;
        Transfer(0x0, msg.sender, _availableSupply);

        uint256 _promoAmount = _promo / users.length;
        for (uint16 i = 0; i < users.length; i++) {
            balances[users[i]] = _promoAmount;
            Transfer(0x0, users[i], _promoAmount);
        }
    }

    function setCut(uint16 _cut) external onlyOwner {
        require(_cut > 0);
        require(_cut < 10000);

        cut = _cut;
    }

    function setMinBet(uint256 _minBet) external onlyOwner {
        require(_minBet > 0);

        minBet = _minBet;
    }

    function addToMemeList(string _meme) external {
        require(memeList[_meme] != true);

        memeList[_meme] = true;

        NewMeme(msg.sender, _meme);
    }

    function countUp() external {
        countingMeme += 1;

        CountUp(msg.sender, countingMeme);
    }
}