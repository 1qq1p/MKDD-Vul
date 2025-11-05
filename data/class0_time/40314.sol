pragma solidity ^0.4.23;


contract Administrable is Mortal{
    
    uint public charityPot;
    uint public highscorePot;
    uint public affiliatePot;
    uint public surprisePot;
    uint public developerPot;
    
    uint public charityPercent = 25;
    uint public highscorePercent = 50;
    uint public affiliatePercent = 50;
    uint public surprisePercent = 25;
    uint public developerPercent = 50;
    uint public winnerPercent = 800;
    
    address public highscoreHolder;
    address public signer;
    
    mapping (address => uint) public affiliateBalance;

    uint public minStake;
    uint public maxStake;

    
    mapping (bytes32 => bool) public used;
    event Withdrawal(uint8 pot, address receiver, uint value);

    modifier validAddress(address receiver){
        require(receiver != 0x0, "invalid receiver");
        _;
    }


    


    function setMinimumWait(uint newMin) public onlyOwner{
        minimumWait = newMin;
    }

    


    function withdrawDeveloperPot(address receiver) public onlyOwner validAddress(receiver){
        uint value = developerPot;
        developerPot = 0;
        receiver.transfer(value);
        emit Withdrawal(0, receiver, value);
    }

    


    function donate(address charity) public onlyOwner validAddress(charity){
        uint value = charityPot;
        charityPot = 0;
        charity.transfer(value);
        emit Withdrawal(1, charity, value);
    }

    


    function withdrawHighscorePot(address receiver) public validAddress(receiver){
        require(msg.sender == highscoreHolder);
        uint value = highscorePot;
        highscorePot = 0;
        receiver.transfer(value);
        emit Withdrawal(2, receiver, value);
    }

    


    function withdrawAffiliateBalance(address receiver) public validAddress(receiver){
        uint value = affiliateBalance[msg.sender];
        require(value > 0);
        affiliateBalance[msg.sender] = 0;
        receiver.transfer(value);
        emit Withdrawal(3, receiver, value);
    }

    


    function withdrawSurprisePot(address receiver) public onlyOwner validAddress(receiver){
        uint value = surprisePot;
        surprisePot = 0;
        receiver.transfer(value);
        emit Withdrawal(4, receiver, value);
    }

    


    function withdrawSurprisePotUser(uint value, uint expiry, uint8 v, bytes32 r, bytes32 s) public{
        require(expiry >= now, "signature expired");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, value, expiry));
        require(!used[hash], "same signature was used before");
        require(ecrecover(hash, v, r, s) == signer, "invalid signer");
        require(value <= surprisePot, "not enough in the pot");
        surprisePot -= value;
        used[hash] = true;
        msg.sender.transfer(value);
        emit Withdrawal(4, msg.sender, value);
    }

    


    function setSigner(address signingAddress) public onlyOwner{
        signer = signingAddress;
    }

    


    function setPercentages(uint affiliate, uint charity, uint dev, uint highscore, uint surprise) public onlyOwner{
        uint sum =  affiliate + charity + highscore + surprise + dev;
        require(sum < 500, "winner should not lose money");
        charityPercent = charity;
        affiliatePercent = affiliate;
        highscorePercent = highscore;
        surprisePercent = surprise;
        developerPercent = dev;
        winnerPercent = 1000 - sum;
    }

    function setMinMax(uint newMin, uint newMax) public onlyOwner{
        minStake = newMin;
        maxStake = newMax;
    }
}
