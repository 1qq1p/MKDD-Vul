pragma solidity ^0.4.21;





library SafeMath {

    


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        return a / b;
    }

    


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    


    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}






contract ASGToken is StandardToken {

    string constant public name = "ASGARD";
    string constant public symbol = "ASG";
    uint256 constant public decimals = 18;

    address constant public marketingWallet = 0x341570A97E15DbA3D92dcc889Fff1bbd6709D20a;
    uint256 public marketingPart = uint256(2100000000).mul(10 ** decimals); 

    address constant public airdropWallet = 0xCB3D939804C97441C58D9AC6566A412768a7433B;
    uint256 public airdropPart = uint256(1750000000).mul(10 ** decimals); 

    address constant public bountyICOWallet = 0x5570EE8D93e730D8867A113ae45fB348BFc2e138;
    uint256 public bountyICOPart = uint256(375000000).mul(10 ** decimals); 

    address constant public bountyECOWallet = 0x89d90bA8135C77cDE1C3297076C5e1209806f048;
    uint256 public bountyECOPart = uint256(375000000).mul(10 ** decimals); 

    address constant public foundersWallet = 0xE03d060ac22fdC21fDF42eB72Eb4d8BA2444b1B0;
    uint256 public foundersPart = uint256(2500000000).mul(10 ** decimals); 

    address constant public cryptoExchangeWallet = 0x5E74DcA28cE21Bf066FC9eb7D10946316528d4d6;
    uint256 public cryptoExchangePart = uint256(400000000).mul(10 ** decimals); 

    address constant public ICOWallet = 0xCe2d50c646e83Ae17B7BFF3aE7611EDF0a75E03d;
    uint256 public ICOPart = uint256(10000000000).mul(10 ** decimals); 

    address constant public PreICOWallet = 0x83D921224c8B3E4c60E286B98Fd602CBa5d7B1AB;
    uint256 public PreICOPart = uint256(7500000000).mul(10 ** decimals); 

    uint256 public INITIAL_SUPPLY = uint256(25000000000).mul(10 ** decimals); 

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;

        balances[marketingWallet] = marketingPart;
        emit Transfer(this, marketingWallet, marketingPart); 

        balances[airdropWallet] = airdropPart;
        emit Transfer(this, airdropWallet, airdropPart); 

        balances[bountyICOWallet] = bountyICOPart;
        emit Transfer(this, bountyICOWallet, bountyICOPart); 

        balances[bountyECOWallet] = bountyECOPart;
        emit Transfer(this, bountyECOWallet, bountyECOPart); 

        balances[foundersWallet] = foundersPart;
        emit Transfer(this, foundersWallet, foundersPart); 

        balances[cryptoExchangeWallet] = cryptoExchangePart;
        emit Transfer(this, cryptoExchangeWallet, cryptoExchangePart); 

        balances[ICOWallet] = ICOPart;
        emit Transfer(this, ICOWallet, ICOPart); 

        balances[PreICOWallet] = PreICOPart;
        emit Transfer(this, PreICOWallet, PreICOPart); 
    }

}
