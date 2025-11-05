pragma solidity ^0.4.24;






contract Gerc is StandardToken, Ownable {
    using SafeMath for uint256;

    string public constant name = "Game Eternal Role Chain";
    string public constant symbol = "GERC";
    uint8 public constant decimals = 3;
    
    uint256 constant INITIAL_SUPPLY = 100000000000 * (10 ** uint256(decimals));
    
    string public website = "www.gerc.club";
    
    string public icon = "/css/gerc.png";

    


    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);    
    }

    


    function airdrop(address[] payees, uint256 airdropValue) public onlyOwner returns(bool) {
        uint256 _size = payees.length;       
        uint256 amount = airdropValue.mul(_size);
        require(amount <= balances[owner], "balance error"); 

        for (uint i = 0; i<_size; i++) {
            if (payees[i] == address(0)) {
                amount = amount.sub(airdropValue);
                continue;   
            }
            balances[payees[i]] = balances[payees[i]].add(airdropValue);
            emit Transfer(owner, payees[i], airdropValue);
        }        
        balances[owner] = balances[owner].sub(amount);
        return true;
    }

    


    function setWebInfo(string _website, string _icon) public onlyOwner returns(bool){
        website = _website;
        icon = _icon;
        return true;
    }
}