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






contract MyAdvancedToken is MintableToken {

    string public name;
    string public symbol;
    uint8 public decimals;

    event TokensBurned(address initiatior, address indexed _partner, uint256 _tokens);


    


    constructor() public {
        name = "Electronic Energy Coin";
        symbol = "E2C";
        decimals = 18;
        totalSupply = 1000000000e18;

        address beneficial = 0x6784520Ac7fbfad578ABb5575d333A3f8739A5af;
        uint256 beneficialAmt = 1000000e18; 
        uint256 founderAmt = totalSupply.sub(1000000e18);

        balances[msg.sender] = founderAmt;
        balances[beneficial] = beneficialAmt;
        emit Transfer(0x0, msg.sender, founderAmt);
        emit Transfer(0x0, beneficial, beneficialAmt);
        
    }

    modifier onlyFounder {
        require(msg.sender == founder);
        _;
    }

    event NewFounderAddress(address indexed from, address indexed to);

    function changeFounderAddress(address _newFounder) public onlyFounder {
        require(_newFounder != 0x0);
        emit NewFounderAddress(founder, _newFounder);
        founder = _newFounder;
    }

    




    function burnTokens(address _partner, uint256 _tokens) public onlyFounder {
        require(balances[_partner] >= _tokens);
        balances[_partner] = balances[_partner].sub(_tokens);
        totalSupply = totalSupply.sub(_tokens);
        emit TokensBurned(msg.sender, _partner, _tokens);
    }
}